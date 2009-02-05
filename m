From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [PATCH] [RESEND] iproute2 : invalid burst/cburst calculation with hrtimers
Date: Thu, 5 Feb 2009 13:09:06 +0200
Message-ID: <200902051309.06958.denys@visp.net.lb>
References: <200902021926.17768.denys@visp.net.lb> <200902051101.35327.denys@visp.net.lb> <20090205100853.GB4305@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:39691 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbZBELJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 06:09:01 -0500
In-Reply-To: <20090205100853.GB4305@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 05 February 2009 12:08:53 Jarek Poplawski wrote:
>
> I lost your point... I think it's just like in your (and Martin's)
> description to your patch. Plus you wrote it was tested OK?!
Martin just pointed me, that burst/cburst probably is too small.

I found, that it is too small because of get_hz(). Actually on highres it will 
be always 1600 (default minimal value).

>
> BTW, did you try to set the same (29kb) burst/cburst manually? Did
> you try with half of it (15kb)?
I didn't, i guess i must calculate corresponding rates for another classes 
equally. But i try to set HZ variable to 2000 for example, i will see:

class htb 1:10 parent 1:2 rate 220000Kbit ceil 220000Kbit burst 15317b cburst 
15317b
 Sent 100864803 bytes 115615 pkt (dropped 0, overlimits 0 requeues 0)
 rate 15426Kbit 2106pps backlog 0b 0p requeues 0
 lended: 29467 borrowed: 0 giants: 0
 tokens: 533 ctokens: 533

But it is difficult to know, if it works fine or not. I will try to do more 
tests for 2000 and 10000 HZ. The issue, that on that point where i had fault, 
now is less load, so i have to find another place where i can test 
differences.

>
> > P.S. Maybe a case, when some guy was not able to reach his gigabit with
> > HTB shaper, i remember there was flowing some discussing, was somehow
> > similar as my case.
>
> I don't remember this, but with current defaults it's really a problem
> for higher rates.
>
> Jarek P.


