From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] Add support for configuring Infiniband GUIDs
Date: Fri, 6 May 2016 20:05:01 +0300
Message-ID: <572CCEBD.5090602@cogentembedded.com>
References: <1462549405-16003-1-git-send-email-eli@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eli Cohen <eli@mellanox.com>, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:34729 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758424AbcEFRFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 13:05:06 -0400
Received: by mail-lf0-f42.google.com with SMTP id m64so138179785lfd.1
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 10:05:05 -0700 (PDT)
In-Reply-To: <1462549405-16003-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/06/2016 06:43 PM, Eli Cohen wrote:

> Add two NLA's that allow configuration of Infiniband node or port GUIDs
> by referencing the IPoIB net device set over then physical function. The
> format to be used is as follows:
>
> ip link set dev ib0 vf 0 node_guid 00:02:c9:03:00:21:6e:70
> ip link set dev ib0 vf 0 port_guid 00:02:c9:03:00:21:6e:78
>
> Issue: 702759
> Change-Id: I5ffb54d6de7bfa8650bf5818f484279914991d6e
> Signed-off-by: Eli Cohen <eli@mellanox.com>
> ---
>   ip/iplink.c           | 40 ++++++++++++++++++++++++++++++++++++++++
>   man/man8/ip-link.8.in | 12 +++++++++++-
>   2 files changed, 51 insertions(+), 1 deletion(-)
>
> diff --git a/ip/iplink.c b/ip/iplink.c
> index d2e586b6d133..3f885defdfeb 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -237,6 +237,30 @@ struct iplink_req {
>   	char			buf[1024];
>   };
>
> +static int extract_guid(__u64 *guid, char *arg)
> +{
> +	__u64 ret;
> +	int g[8];
> +	int err;
> +
> +	err = sscanf(arg, "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
> +		     g, g + 1, g + 2, g + 3, g + 4, g + 5, g + 6, g + 7);
> +	if (err != 8)

    Strange name for a variable, if sscanf() returns # of fields read... In 
fact, you don't even need this variable.

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
