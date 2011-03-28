From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2 v2] tg3: Don't use IRQF_SAMPLE_RANDOM
Date: Mon, 28 Mar 2011 21:32:24 +0100
Message-ID: <1301344344.27727.15.camel@bwh-desktop>
References: <1301314543-3666-1-git-send-email-martinez.javier@gmail.com>
	 <AANLkTi=Qkf2qn6nQ-6AXE8LtFSD++=eZRxa6ND6KPsk1@mail.gmail.com>
	 <1301332822.2716.12.camel@bwh-desktop>
	 <201103282208.05830.ffainelli@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Javier Martinez Canillas <martinez.javier@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Dan Carpenter <error27@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Florian Fainelli <ffainelli@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25340 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974Ab1C1Uc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 16:32:28 -0400
In-Reply-To: <201103282208.05830.ffainelli@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-28 at 22:08 +0200, Florian Fainelli wrote:
> Hello,
> 
> On Monday 28 March 2011 19:20:22 Ben Hutchings wrote:
> > On Mon, 2011-03-28 at 17:46 +0200, Javier Martinez Canillas wrote:
> > > On Mon, Mar 28, 2011 at 2:25 PM, Eric Dumazet <eric.dumazet@gmail.com> 
> wrote:
> > > > 1) We dont believe its Janitor material ;)
> > > > 
> > > > http://thread.gmane.org/gmane.linux.kernel/680723
> > > > 
> > > > http://kerneltrap.org/mailarchive/linux-netdev/2009/4/6/5417754
> > > 
> > > I wasn't aware of this discussion. In one hand network drivers are not
> > > a good source of entropy because they can be controlled externally,
> > > but in embedded systems with only network cards (no video, audio,
> > > keyboard, etc) the only source of entropy they have is their network
> > > cards (at the kernel level i.e: not using EGD to feed /dev/random).
> > 
> > It may be the only source of entropy, but given how poor a source it is
> > these drivers are basically telling sweet little lies to the kernel and
> > the applications that demand real random numbers.
> > 
> > This also applies to many servers just as much as embedded systems.
> 
> Indeed, this is the reason why bcm63xx_enet.c for instance contributes to the 
> general entropy of the system, because it is used on MIPS based ADSL routers 
> where we have little or no other source of entropy.
> 
> Still even poor entropy is better than none on such devices imho.
[...]

Well, only if it's treated as such.

add_timer_randomness() does try to measure how much entropy it's getting
from the time, which should address the problem of interrupt moderation
causing predictable interrupts.  However I strongly suspect that its
tests cannot protect against deliberately timed packets, particularly if
get_cycles() has low resolution.  (On MIPS, get_cycles() always returns
0, although the comment before suggests that this is possible to do
better.)

I notice that there is an internal option 'dont_count_entropy' which
would allow interrupts to add entropy without it increasing the
estimated total entropy in the pool.  If that was set for network
interrupts, they could be used to improve the quality of /dev/urandom,
get_random_bits(), etc. without compromising applications that demand
real randomness.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

