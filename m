From: "Gilles Espinasse" <g.esp@free.fr>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses ofIRQF_SAMPLE_RANDOM
Date: Sun, 18 May 2008 08:41:10 +0200
Message-ID: <10a001c8b8b2$28afd2c0$f9b5a8c0@pii350>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <20080516161029.44ded734@core> <0f7201c8b790$9c2a2340$f9b5a8c0@pii350> <20080517220258.GC8140@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Adrian Bunk" <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp7-g19.free.fr ([212.27.42.64]:50335 "EHLO smtp7-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbYERGoI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2008 02:44:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


----- Original Message ----- 
From: "Adrian Bunk" <bunk@kernel.org>
To: "Gilles Espinasse" <g.esp@free.fr>
Cc: <netdev@vger.kernel.org>; <linux-kernel@vger.kernel.org>
Sent: Sunday, May 18, 2008 12:02 AM
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses
ofIRQF_SAMPLE_RANDOM


> On Fri, May 16, 2008 at 10:08:29PM +0200, Gilles Espinasse wrote:
> >
> > That's funny
> > It does look to disturb some kernel developper that ethernet may be
sniffed
> > to feed a RNG
> > even that could be very hard to reach any effective result in the case
of a
> > machine splitting different network segments.
> >
> > In the same time, it does not disturb openssl developpers to include non
> > initialised memory that may or may not be predictable to feed a RNG.
> > http://marc.info/?l=openssl-dev&m=121095151003011&w=2
>
> Why should it disturb them?
>
> As is explained in the email you quote it cannot make the RNG
> output worse.
>
Yes that's the whole point.
Why remove IRQF_SAMPLE_RANDOM if "it cannot make the RNG output worse."
We should not care if network traffic can be sniffed in some configurations
(plus sniffing could be very unlikely in some others).

There is some objections that I understand (less IRQ with NAPI or less IRQ
with more network traffic). But there is still the problem to have other
entropy supplier for any existing machines without hw_random chip.

For the few machines with a supported hw_random chip, rng-tools should do
the job (and far better)

I look at other possible entropy solutions proposed by Jeff Garzic
http://sourceforge.net/projects/egd
That's for system without /dev/random and linux has /dev/random.

http://sourceforge.net/projects/prngd
README say
"- If you have a UNIX version providing /dev/urandom or /dev/random you
  probably won't need PRNGD at all."

So I didn't find an operational replacement solution yet now.
I don't say something is not doable re-using parts of egd or prngd to feed
the entropy pool.

I had experiences with the entropy pool empty since 2.6.12.
I am running headless machines to compile with not much other activities
sometime.
On a headless machine running 2.6.11 kernel, openswan-1.0.10 was compiling
fine.
On that same machine upgraded to 2.6.12 vanillia kernel, package compilation
will wait I feed
the entropy pool by some actions (keyboard/console) during ipsec.secrets
generation.
Failed instruction was rsasigkey --verbose 2192

Problem was caused by the changes to feed the entropy pool on 2.6.12
2.6.25 fail the same way on that machine.
Each time any source to feed the entropy pool is removed, /dev/random
situation is always worst and DOS may happen.

I understand  IRQF_SAMPLE_RANDOM on a network card may be not the GREAT
solution.
In fact, this machine use via_rhine nic driver that does not have
SAMPLE_RANDOM collection even in 2.6.11 (and there not much traffic on this
machine when packages cache is up to date).

Are network drivers better without SAMPLE_RANDOM?
My understanding of openssl developper answer is same as yours :
"it cannot make the RNG output worse."
So why remove SAMPLE_RANDOM on network cards today if there is no
replacement solution ready for x% of machines running linux actually?

How many SAMPLE_RANDOM sources remain that have a chance to be run on the
average machine running linux?

Gilles

