From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [RESEND] iproute2 : invalid burst/cburst calculation
	with hrtimers
Date: Thu, 5 Feb 2009 10:08:53 +0000
Message-ID: <20090205100853.GB4305@ff.dom.local>
References: <200902021926.17768.denys@visp.net.lb> <200902050124.05969.denys@visp.net.lb> <20090205073832.GA4305@ff.dom.local> <200902051101.35327.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:39745 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755085AbZBEKJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 05:09:00 -0500
Received: by nf-out-0910.google.com with SMTP id d3so19439nfc.21
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2009 02:08:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200902051101.35327.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2009 at 11:01:35AM +0200, Denys Fedoryschenko wrote:
> Well, i don't know well what's wrong, but:
> 
> I have enough powerful router, 2x Quad Core 2 - 2.8 Ghz
> 4 x e1000e
> 
> And if i just try to shape interface for 200 Mbps with default iproute2 from 
> git (and latest stable release same situation), i am getting too low 
> burst/cburst. Sometimes it is even miscalculated (it can become 1500 byte, 
> sometimes, while 1600 is minimum) , because yes, Stephen right, it needs 
> float.
> BUT.
> Even i set manually twice more burst/cburst, it is just not enough for 200 
> Mbps. I am checking on Cisco, rate is reaching max 180-185Mbps, and even on 
> this rate buffering in qdiscs and as result jittering hard.
> So this 100 bytes, which probably missing, really doesn't matter.
> 
> With 1000 HZ i have
> class htb 1:10 parent 1:2 rate 220000Kbit ceil 220000Kbit burst 29067b cburst 
> 29067b
>  Sent 14027734219153 bytes 590886842 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 122452Kbit 17131pps backlog 0b 0p requeues 0
>  lended: 171333348 borrowed: 0 giants: 0
>  tokens: 980 ctokens: 980
> 
> And it works quite well and precise.

I lost your point... I think it's just like in your (and Martin's)
description to your patch. Plus you wrote it was tested OK?!

BTW, did you try to set the same (29kb) burst/cburst manually? Did
you try with half of it (15kb)?

> P.S. Maybe a case, when some guy was not able to reach his gigabit with HTB 
> shaper, i remember there was flowing some discussing, was somehow similar as 
> my case.

I don't remember this, but with current defaults it's really a problem
for higher rates.

Jarek P.
