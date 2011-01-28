From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v2] gianfar: Fall back to software tcp/udp checksum on
 oldercontrollers
Date: Fri, 28 Jan 2011 10:56:10 -0600
Message-ID: <20110128105610.4a518456@udp111988uds.am.freescale.net>
References: <640295.36173.qm@web37608.mail.mud.yahoo.com>
	<AE90C24D6B3A694183C094C60CF0A2F6D8AC2E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:50270
	"EHLO VA3EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755267Ab1A1Q5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 11:57:24 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AC2E@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Jan 2011 09:10:46 +0000
David Laight <David.Laight@ACULAB.COM> wrote:

>  
> > +		if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_12)
> > +			     && ((unsigned long)fcb % 0x20) > 0x18)) {
> 
> You need to check the generated code, but I think you need:
> 
>     if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_12))
> 	     && unlikely(((unsigned long)fcb % 0x20) > 0x18))
> 
> ie unlikely() around both the primitive comparisons.

Is the first condition actually unlikely?  If you've got affected
hardware, you'll hit it every time.

If packets with the problematic alignment are rare, seems like it'd be
better to check that first.

-Scott

