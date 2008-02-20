From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Wed, 20 Feb 2008 11:24:50 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802201122150.26109@fbirervta.pbzchgretzou.qr>
References: <200801291316.m0TDGivY024953@hera.kernel.org>
 <1203428949.3223.25.camel@shinybook.infradead.org>  <47BAE13D.4060206@trash.net>
 <1203431447.3223.33.camel@shinybook.infradead.org> <47BAEB6C.1030609@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Woodhouse <dwmw2@infradead.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:37760 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbYBTKYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 05:24:52 -0500
In-Reply-To: <47BAEB6C.1030609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Feb 19 2008 15:45, Patrick McHardy wrote:
>> 
>> It's in busybox 1.9.1. Just including <netinet/in.h> seems to be
>> sufficient to make it happy again. I wonder if netfilter.h should
>> include that for itself?
>
> That would break iptables compilation, which already includes
> linux/in.h in some files. I guess the best fix for now is to
> include netinet/in.h in busybox and long-term clean this up
> properly.
>

If <linux/netfilter.h> includes <linux/in.h>, userspace compilation
fails (clashing defs, etc.); if <linux/netfilter.h> includes
<netinet/in.h>, kernel compilation fails (file not found).

What comes to mind is the ugly hack we had for a few days:

#ifdef __KERNEL__
#	include <linux/in.h>
#else
#	include <netinet/in.h>
#endif

and I think we should not impose any inclusion rules on userspace
this way.

Right now, it is solved this way:

kernel .c files explicitly include <linux/in.h> when loading
<linux/netfilter.h>,

userspace .c files explicitly includ <netinet/in.h> when loading
<linux/netfilter.h>. And that seems to work out.

