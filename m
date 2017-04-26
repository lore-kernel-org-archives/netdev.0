From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [iproute2] iplink: add support for IFLA_CARRIER attribute
Date: Wed, 26 Apr 2017 12:59:34 +0300
Message-ID: <e05b8fa4-feaa-d1f3-684e-5dabf87c542e@cumulusnetworks.com>
References: <1493190519-5518-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35643 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948807AbdDZJ7o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 05:59:44 -0400
Received: by mail-wm0-f52.google.com with SMTP id w64so45359455wma.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 02:59:43 -0700 (PDT)
In-Reply-To: <1493190519-5518-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/04/17 10:08, Zhang Shengju wrote:
> Add support to set IFLA_CARRIER attribute.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  ip/iplink.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 

You should also update the ip-link man page with this new option.

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

Please leave a blank line between the variable definition and the code.

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
> 
