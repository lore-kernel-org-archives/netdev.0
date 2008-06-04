From: Martin Devera <devik@cdi.cz>
Subject: Re: [PATCH 0/2] HTB scheduler HTB_HYSTERESIS modifications
Date: Wed, 04 Jun 2008 17:31:41 +0200
Message-ID: <4846B55D.4060306@cdi.cz>
References: <1212501803.13164.27.camel@localhost.localdomain>	 <48469323.8000506@cdi.cz> <1212589713.13164.75.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wifcom.cz ([89.185.251.8]:53290 "EHLO wifcom.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752589AbYFDPcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 11:32:04 -0400
In-Reply-To: <1212589713.13164.75.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I'm thinking about removing HYSTERESIS code altogether, but
>> (and it holds for setting HYSTERESIS=off as default) 
> 
> I prefer a turn knob, where the default is off.

Ok. As seen from interrupt load below, it is reasonable.

> With current testing (on 2.6.25.4) I could not see any changes with CPU
> usage, but thats probably caused by the fast CPU on the test system
> (Dual Xeon). BUT an interesting observation was that the number of
> interrupts increased significantly, from approx 1300 to 2000 per sec.
> The other observation was that I got significantly less jitter.

Interesting. It is probably result of merging of subsequent yellow/red
states without going to green for while. The traffic is more bursty then
(it is no longer only timer-granular, but {c,}burst sized bursts are
FORCED in output) but NIC driver can emit more outgoing packets
per in single "buffer free" interrupt.

>> Also, I'm a bit busy for a few weeks, would you be able/interested
>> to do such testing ?
> 
> Okay, lets wait until I get this kernel into our real-life production
> system.  Then I can report on the real-life impact on CPU performance.

Thanks, I'll try to set some test up later. With large class-count as
state changes will cost more then (RB tree deletes/inserts).

Regarding your intr/sec count, what about to keep default value
of hysteresis switch as "on" (just to be on safe side) ?
I'm afraid what that 40% larger interrupt load might do with bigger
routers (I already got some performance related questions from ppl
with hundreds classes on 100's Mb links).

m.
