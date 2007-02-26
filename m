From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [RFC] div64_64 support
Date: Tue, 27 Feb 2007 00:02:50 +0100 (MET)
Message-ID: <Pine.LNX.4.61.0702262348140.23355@yvahk01.tjqt.qr>
References: <20070223170527.4ca695b2@freekitty> <Pine.LNX.4.61.0702262108010.23355@yvahk01.tjqt.qr>
 <20070226143127.5c74bec9@freekitty>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tmailer.gwdg.de ([134.76.10.23]:60545 "EHLO tmailer.gwdg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161380AbXBZXDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 18:03:44 -0500
In-Reply-To: <20070226143127.5c74bec9@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 26 2007 13:28, Stephen Hemminger wrote:
>> 
>> ./arch/arm26/lib/udivdi3.c
>> ./arch/sh/lib/udivdi3.c
>> ./arch/sparc/lib/udivdi3.S
>> 
>> should not this be consolidated too?
>
>Hmm. Those are the GCC internal versions, that are picked up but
>doing divide in place. Do we want to allow general 64 bit in kernel to
>be easily used? It could cause sloppy slow code, but it would look
>cleaner.

Then our reviewers should catch it, and if not, the janitors will
(/me winks at R.P.J.Day and trivial@).

>@@ -134,7 +112,7 @@
> 	 */
> 	do {
> 		x1 = x;
>-		x = (2 * x + (uint32_t) div64_64(a, x*x)) / 3;
>+		x = (2 * x + (u32) (a / x*x)) / 3;

Eye see a bug.

Previously there was div64_64(a, x*x) which is equivalent to
(a)/(x*x), or just: a/(x^2). But now you do a/x*x, which is
equivalent to a*x/x (in the domain of real numbers). Furthermore,
a/x*x is a-(a%x), which does not even remotely match a/(x^2).

Please keep the math intact, thank you ;-)



Jan
-- 
