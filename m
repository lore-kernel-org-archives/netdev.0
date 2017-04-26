From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2] iplink: add support for IFLA_CARRIER attribute
Date: Wed, 26 Apr 2017 08:07:32 -0700
Message-ID: <20170426080732.51f56b8c@xeon-e3>
References: <1493190519-5518-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36448 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1437737AbdDZPJj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 11:09:39 -0400
Received: by mail-pf0-f173.google.com with SMTP id 194so1432797pfv.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 08:09:39 -0700 (PDT)
In-Reply-To: <1493190519-5518-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Apr 2017 15:08:39 +0800
Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:

> Add support to set IFLA_CARRIER attribute.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  ip/iplink.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/ip/iplink.c b/ip/iplink.c
> index 866ad72..263bfdd 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -72,6 +72,7 @@ void iplink_usage(void)
>  		"	                  [ allmulticast { on | off } ]\n"
>  		"	                  [ promisc { on | off } ]\n"
>  		"	                  [ trailers { on | off } ]\n"
> +		"	                  [ carrier { on | off } ]\n"
>  		"	                  [ txqueuelen PACKETS ]\n"
>  		"	                  [ name NEWNAME ]\n"
>  		"	                  [ address LLADDR ]\n"
> @@ -673,6 +674,17 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
>  				req->i.ifi_flags |= IFF_NOARP;
>  			else
>  				return on_off("arp", *argv);
> +		} else if (strcmp(*argv, "carrier") == 0) {
> +			int carrier;
> +			NEXT_ARG();
> +			if (strcmp(*argv, "on") == 0)
> +				carrier = 1;
> +			else if (strcmp(*argv, "off") == 0)
> +				carrier = 0;
> +			else
> +				return on_off("carrier", *argv);
> +
> +			addattr8(&req->n, sizeof(*req), IFLA_CARRIER, carrier);
>  		} else if (strcmp(*argv, "vf") == 0) {
>  			struct rtattr *vflist;
>  

The general policy of ip link command is all options should be invertable.
There are some VPN's that use this to save and restore state. So if you add
an option to set something there should be similar output under the detailed show command.
