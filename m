From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [PATCH] [RESEND] iproute2 : invalid burst/cburst calculation with hrtimers
Date: Thu, 5 Feb 2009 11:01:35 +0200
Message-ID: <200902051101.35327.denys@visp.net.lb>
References: <200902021926.17768.denys@visp.net.lb> <200902050124.05969.denys@visp.net.lb> <20090205073832.GA4305@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:36594 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbZBEJBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 04:01:30 -0500
In-Reply-To: <20090205073832.GA4305@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, i don't know well what's wrong, but:

I have enough powerful router, 2x Quad Core 2 - 2.8 Ghz
4 x e1000e

And if i just try to shape interface for 200 Mbps with default iproute2 from 
git (and latest stable release same situation), i am getting too low 
burst/cburst. Sometimes it is even miscalculated (it can become 1500 byte, 
sometimes, while 1600 is minimum) , because yes, Stephen right, it needs 
float.
BUT.
Even i set manually twice more burst/cburst, it is just not enough for 200 
Mbps. I am checking on Cisco, rate is reaching max 180-185Mbps, and even on 
this rate buffering in qdiscs and as result jittering hard.
So this 100 bytes, which probably missing, really doesn't matter.

With 1000 HZ i have
class htb 1:10 parent 1:2 rate 220000Kbit ceil 220000Kbit burst 29067b cburst 
29067b
 Sent 14027734219153 bytes 590886842 pkt (dropped 0, overlimits 0 requeues 0)
 rate 122452Kbit 17131pps backlog 0b 0p requeues 0
 lended: 171333348 borrowed: 0 giants: 0
 tokens: 980 ctokens: 980

And it works quite well and precise.

P.S. Maybe a case, when some guy was not able to reach his gigabit with HTB 
shaper, i remember there was flowing some discussing, was somehow similar as 
my case.

On Thursday 05 February 2009 09:38:32 Jarek Poplawski wrote:
>
> I think HZ doesn't matter much in this place, because if it's ever
> triggered there is something really wrong and precision is lost.
> Anyway, this place was changed a bit in net-next.
>
> I guess I could misunderstand your previous question. If you mean this
> previous thread, then yes, IMHO CONFIG_HZ should matter for precision
> (especially places where similar loops use all such jiffies in "normal"
> situations). On the other hand, maybe I'm wrong, but using HZ 1000
> with HIGH_RES_TIMERS looks quite obvious to me...
>
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


