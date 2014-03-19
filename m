From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2 -next 2/2] ipxfrm: allow to setup filter
 when dumping SA
Date: Wed, 19 Mar 2014 13:39:55 -0700
Message-ID: <20140319133955.6458fe5a@nehalam.linuxnetplumber.net>
References: <1395247928-9954-1-git-send-email-nicolas.dichtel@6wind.com>
	<1395247928-9954-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:54217 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755806AbaCSUj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 16:39:58 -0400
Received: by mail-pd0-f176.google.com with SMTP id r10so9132362pdi.7
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 13:39:58 -0700 (PDT)
In-Reply-To: <1395247928-9954-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Mar 2014 17:52:08 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
> index 140a4503b799..8295223f8118 100644
> --- a/ip/xfrm_state.c
> +++ b/ip/xfrm_state.c
> @@ -1136,7 +1136,35 @@ static int xfrm_state_list_or_deleteall(int argc, char **argv, int deleteall)
>  		}
>  
>  	} else {
> -		if (rtnl_wilddump_request(&rth, preferred_family, XFRM_MSG_GETSA) < 0) {
> +		struct xfrm_address_filter addrfilter;
> +		struct {
> +			struct nlmsghdr n;
> +			char buf[NLMSG_BUF_SIZE];
> +		} req;
> +
> +		memset(&addrfilter, 0, sizeof(addrfilter));
> +		addrfilter.family = filter.xsinfo.family;
> +		memcpy(&addrfilter.saddr, &filter.xsinfo.saddr,
> +		       sizeof(xfrm_address_t));
> +		addrfilter.splen = filter.id_src_mask;
> +		memcpy(&addrfilter.daddr, &filter.xsinfo.id.daddr,
> +		       sizeof(xfrm_address_t));
> +		addrfilter.dplen = filter.id_dst_mask;
> +

I prefer to see C99 initializers for stack variables when possible
instead of using memset().
