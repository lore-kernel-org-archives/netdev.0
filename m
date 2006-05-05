From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 1.3-rc1
Date: Fri, 5 May 2006 10:45:36 -0700
Message-ID: <20060505104536.2baefa5e@localhost.localdomain>
References: <1146667951.3056.25.camel@fc5test.deadmoose.com>
	<20060503120507.4558c675@localhost.localdomain>
	<445B626B.1070407@gentoo.org>
	<20060505173509.GK2757@cip.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, Bill Hoover <bill@luminescent.com>,
	Bertrand Jacquin <beber@gna.org>, micheleschi@libero.it,
	netdev@vger.kernel.org, teppic74@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:2703 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751156AbWEESHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 14:07:39 -0400
To: Thomas Glanzmann <sithglan@stud.uni-erlangen.de>
In-Reply-To: <20060505173509.GK2757@cip.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 5 May 2006 19:35:09 +0200
Thomas Glanzmann <sithglan@stud.uni-erlangen.de> wrote:

> Hello,
> 
> > >	http://developer.osdl.org/shemminger/prototypes/sky2-1.3-rc1.tar.bz2
> 
> > v0.15:
> > 64 bytes from 10.0.0.138: icmp_seq=2 ttl=64 time=0.467 ms
> 
> > v1.3-rc1:
> > 64 bytes from 10.0.0.138: icmp_seq=4 ttl=64 time=32.9 ms
> 
> I can't confirm this. For me it is just perfect:
> 
> 64 bytes from 89.106.66.1: icmp_seq=1 ttl=64 time=0.278 ms
> 
> 0000:04:00.0 Ethernet controller: Marvell Technology Group Ltd.: Unknown device 4361 (rev 17)
> 
>         Thomas

What is happening is that if there is a misconfiguration and irq routing
is messed up (ie edge trigged). The driver will degenerate to polling every 100ms.
If your system is this misconfigured, then ACPI or the BIOS needs to be fixed
and the driver really only needs to work well enough to get the bug report out ;-)

The older driver was doing rewhacking the Transmit IRQ status timer,
so it would give a bogus transmit status interrupt and that was masking
issues.

