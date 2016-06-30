From: Eli Cohen <eli@mellanox.com>
Subject: RE: [PATCH] Add support for configuring Infiniband GUIDs
Date: Thu, 30 Jun 2016 18:17:25 +0000
Message-ID: <DB5PR05MB184819AC02B440C70E2B7103C5240@DB5PR05MB1848.eurprd05.prod.outlook.com>
References: <1462549405-16003-1-git-send-email-eli@mellanox.com>
 <572CCEBD.5090602@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"shemminger@osdl.org" <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00065.outbound.protection.outlook.com ([40.107.0.65]:57259
	"EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751523AbcGAJ5E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 05:57:04 -0400
In-Reply-To: <572CCEBD.5090602@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,
I am not following on your comment. Are you referring to the variable 'g'? It's just a short name to make the code more readable. I also don't follow your comment on the fact that sscanf returns the number of arguments read. Please explain.

Eli

-----Original Message-----
From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com] 
Sent: Friday, May 06, 2016 12:05 PM
To: Eli Cohen <eli@mellanox.com>; shemminger@osdl.org
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH] Add support for configuring Infiniband GUIDs

Hello.

On 05/06/2016 06:43 PM, Eli Cohen wrote:

> Add two NLA's that allow configuration of Infiniband node or port 
> GUIDs by referencing the IPoIB net device set over then physical 
> function. The format to be used is as follows:
>
> ip link set dev ib0 vf 0 node_guid 00:02:c9:03:00:21:6e:70 ip link set 
> dev ib0 vf 0 port_guid 00:02:c9:03:00:21:6e:78
>
> Issue: 702759
> Change-Id: I5ffb54d6de7bfa8650bf5818f484279914991d6e
> Signed-off-by: Eli Cohen <eli@mellanox.com>
> ---
>   ip/iplink.c           | 40 ++++++++++++++++++++++++++++++++++++++++
>   man/man8/ip-link.8.in | 12 +++++++++++-
>   2 files changed, 51 insertions(+), 1 deletion(-)
>
> diff --git a/ip/iplink.c b/ip/iplink.c index 
> d2e586b6d133..3f885defdfeb 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -237,6 +237,30 @@ struct iplink_req {
>   	char			buf[1024];
>   };
>
> +static int extract_guid(__u64 *guid, char *arg) {
> +	__u64 ret;
> +	int g[8];
> +	int err;
> +
> +	err = sscanf(arg, "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
> +		     g, g + 1, g + 2, g + 3, g + 4, g + 5, g + 6, g + 7);
> +	if (err != 8)

    Strange name for a variable, if sscanf() returns # of fields read... In fact, you don't even need this variable.

> +		return -1;
> +
> +	ret = ((__u64)(g[0]) << 56) |
> +	      ((__u64)(g[1]) << 48) |
> +	      ((__u64)(g[2]) << 40) |
> +	      ((__u64)(g[3]) << 32) |
> +	      ((__u64)(g[4]) << 24) |
> +	      ((__u64)(g[5]) << 16) |
> +	      ((__u64)(g[6]) << 8) |
> +	      ((__u64)(g[7]));
> +	*guid = ret;
> +
> +	return 0;
> +}
> +
>   static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
>   			   struct iplink_req *req, int dev_index)
>   {
[...]

MBR, Sergei
