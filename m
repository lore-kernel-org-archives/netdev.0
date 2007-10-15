From: Michael Kerrisk <mtk.manpages@googlemail.com>
Subject: Re: [patch] ipv6.7: IPV6_ROUTER_ALERT sockopt correction
Date: Mon, 15 Oct 2007 08:53:38 +0200
Message-ID: <47130E72.1030604@gmail.com>
References: <20071014111147.GE20850@mcdonald.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-man@vger.kernel.org, netdev@vger.kernel.org,
	Andrew McDonald <andrew@mcdonald.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.191]:19641 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436AbXJOG4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 02:56:43 -0400
Received: by mu-out-0910.google.com with SMTP id i10so1920836mue
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2007 23:56:41 -0700 (PDT)
In-Reply-To: <20071014111147.GE20850@mcdonald.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Andrew,

> I discovered that the current description of the IPV6_ROUTER_ALERT
> sockopt in ipv6.7 is significantly wrong. A patch to fix the
> description is below. I sent a version of this earlier in the year to
> mtk-manpages@gmx.net, but nothing happened with it at the time.

Hmmm -- somehow that message got dropped.  I found it in my trash -- sorry
about that.

I've applied your patch for 2.68.

Thanks,

Michael

> The correction is based on reading the relevant parts of the kernel
> source code, and backed up by some test programs. The main bits of code
> in the kernel (in case someone wants to double-check my update) are
> net/ipv6/ipv6_sockglue.c:ip6_ra_control() and
> net/ipv6/ip6_output.c:ip6_call_ra_chain().
> 
> The patch is against man-pages-2.66.

> --- man7/ipv6.7.orig	2007-10-14 11:59:46.000000000 +0100
> +++ man7/ipv6.7	2007-10-14 12:05:15.000000000 +0100
> @@ -233,10 +233,17 @@
>  Argument is a pointer to boolean.
>  .TP
>  .B IPV6_ROUTER_ALERT
> -Pass all forwarded packets containing an router alert option to
> +Pass forwarded packets containing a router alert hop-by-hop option to
>  this socket.
> -Only allowed for datagram sockets and for root.
> -Argument is a pointer to boolean.
> +Only allowed for SOCK_RAW sockets.
> +The tapped packets are not forwarded by the kernel, it is the
> +user's responsibility to send them out again.
> +Argument is a pointer to an integer.
> +A positive integer indicates a router alert option value to intercept.
> +Packets carrying a router alert option with a value field containing
> +this integer will be delivered to the socket.
> +A negative integer disables delivery of packets with router alert options
> +to this socket.
>  .TP
>  .B IPV6_UNICAST_HOPS
>  Set the unicast hop limit for the socket.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-man" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Michael Kerrisk
maintainer of Linux man pages Sections 2, 3, 4, 5, and 7

Want to help with man page maintenance?  Grab the latest tarball at
http://www.kernel.org/pub/linux/docs/manpages/
read the HOWTOHELP file and grep the source files for 'FIXME'.

