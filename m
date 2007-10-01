From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC][IPv6] Export userland ND options through netlink (RDNSS
 support)
Date: Mon, 01 Oct 2007 20:42:40 +0900 (JST)
Message-ID: <20071001.204240.07591824.yoshfuji@linux-ipv6.org>
References: <20070929174720.GA21678@via.ecp.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: linkfanel@yahoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:51227 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbXJALk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 07:40:56 -0400
In-Reply-To: <20070929174720.GA21678@via.ecp.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <20070929174720.GA21678@via.ecp.fr> (at Sat, 29 Sep 2007 19:47:20 +0200), Pierre Ynard <linkfanel@yahoo.fr> says:

> As discussed before, this patch provides userland with a way to access
> relevant options in Router Advertisements, after they are processed and
> validated by the kernel. Extra options are processed in a generic way;
> this patch only exports RDNSS options described in RFC5006, but support
> to control which options are exported could be easily added.

I basically like this approach at first sight.

> which implies that a userland daemon processing RDNSS options needs a
> way to associate the option to the router that sent it, and fetch its
> lifetime. This kind of information could be included in a header in the
> rtnetlink message (in this version of the patch there is none).

> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index dff3192..f69d415 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -97,6 +97,9 @@ enum {
>  	RTM_SETNEIGHTBL,
>  #define RTM_SETNEIGHTBL	RTM_SETNEIGHTBL
>  
> +	RTM_NEWNDUSEROPT = 68,
> +#define RTM_NEWNDUSEROPT RTM_NEWNDUSEROPT
> +
>  	__RTM_MAX,

Does this imply that we could extend (or reuse) this for all of
NS/NA/RS/RA/Redirect messages?  I think you need to include the
code, type and basic semantics of the message.

If this is only for RA, we should say "RTM_NEWRAUSEROPT" or something.

Regards,

--yoshfuji
