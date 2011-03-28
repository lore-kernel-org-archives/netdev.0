From: Florian Fainelli <ffainelli@freebox.fr>
Subject: Re: [PATCH 2/2 v2] tg3: Don't use IRQF_SAMPLE_RANDOM
Date: Mon, 28 Mar 2011 22:08:05 +0200
Message-ID: <201103282208.05830.ffainelli@freebox.fr>
References: <1301314543-3666-1-git-send-email-martinez.javier@gmail.com> <AANLkTi=Qkf2qn6nQ-6AXE8LtFSD++=eZRxa6ND6KPsk1@mail.gmail.com> <1301332822.2716.12.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Javier Martinez Canillas <martinez.javier@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Dan Carpenter <error27@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:45703 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751001Ab1C1UR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2011 16:17:56 -0400
In-Reply-To: <1301332822.2716.12.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Monday 28 March 2011 19:20:22 Ben Hutchings wrote:
> On Mon, 2011-03-28 at 17:46 +0200, Javier Martinez Canillas wrote:
> > On Mon, Mar 28, 2011 at 2:25 PM, Eric Dumazet <eric.dumazet@gmail.com> 
wrote:
> > > 1) We dont believe its Janitor material ;)
> > > 
> > > http://thread.gmane.org/gmane.linux.kernel/680723
> > > 
> > > http://kerneltrap.org/mailarchive/linux-netdev/2009/4/6/5417754
> > 
> > I wasn't aware of this discussion. In one hand network drivers are not
> > a good source of entropy because they can be controlled externally,
> > but in embedded systems with only network cards (no video, audio,
> > keyboard, etc) the only source of entropy they have is their network
> > cards (at the kernel level i.e: not using EGD to feed /dev/random).
> 
> It may be the only source of entropy, but given how poor a source it is
> these drivers are basically telling sweet little lies to the kernel and
> the applications that demand real random numbers.
> 
> This also applies to many servers just as much as embedded systems.

Indeed, this is the reason why bcm63xx_enet.c for instance contributes to the 
general entropy of the system, because it is used on MIPS based ADSL routers 
where we have little or no other source of entropy.

Still even poor entropy is better than none on such devices imho.

> 
> As you acknowledge, these systems can still get entropy using the EGD
> protocol over a secure channel.  (Or an entropy sampling device such as
> the Entropy Key.)



> 
> > Yes this definitely is not janitor material :)
> > 
> > I just sent the patch because I saw IRQF_SAMPLE_RANDOM in
> > Documentation/feature-removal-schedule.txt. I can resend a patch
> > removing the macro in the remaining network cards if the decision is
> > to remove IRQF_SAMPLE_RANDOM.
> 
> It's not my call, but I would support it.
> 
> Ben.
