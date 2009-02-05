From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [RESEND] iproute2 : invalid burst/cburst calculation
	with hrtimers
Date: Thu, 5 Feb 2009 11:56:32 +0000
Message-ID: <20090205115631.GC4305@ff.dom.local>
References: <200902021926.17768.denys@visp.net.lb> <200902051101.35327.denys@visp.net.lb> <20090205100853.GB4305@ff.dom.local> <200902051309.06958.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:52726 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbZBEL4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 06:56:38 -0500
Received: by fxm13 with SMTP id 13so310936fxm.13
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2009 03:56:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200902051309.06958.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2009 at 01:09:06PM +0200, Denys Fedoryschenko wrote:
> On Thursday 05 February 2009 12:08:53 Jarek Poplawski wrote:
> >
> > I lost your point... I think it's just like in your (and Martin's)
> > description to your patch. Plus you wrote it was tested OK?!
> Martin just pointed me, that burst/cburst probably is too small.
> 
> I found, that it is too small because of get_hz(). Actually on highres it will 
> be always 1600 (default minimal value).

And these are very good points.

> > BTW, did you try to set the same (29kb) burst/cburst manually? Did
> > you try with half of it (15kb)?
> I didn't, i guess i must calculate corresponding rates for another classes 
> equally. But i try to set HZ variable to 2000 for example, i will see:
> 
> class htb 1:10 parent 1:2 rate 220000Kbit ceil 220000Kbit burst 15317b cburst 
> 15317b
>  Sent 100864803 bytes 115615 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 15426Kbit 2106pps backlog 0b 0p requeues 0
>  lended: 29467 borrowed: 0 giants: 0
>  tokens: 533 ctokens: 533
> 
> But it is difficult to know, if it works fine or not. I will try to do more 
> tests for 2000 and 10000 HZ. The issue, that on that point where i had fault, 
> now is less load, so i have to find another place where i can test 
> differences.

I don't know where else in tc this HZ env. variable is used, so this
could change more than you need. I only wondered if setting this
manually works, so one try should be enough.

Since you tested with double size burst (~3kb?) and it didn't work,
then we know even 10000 (10x) get_hz() would be wrong. This 2x case
is only for curiosity but I think there is no reason to use more than
1000HZ for setting these defaults in tc.

Jarek P.
