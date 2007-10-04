From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: PROBLEM: system freezes on starting ne2k-pci + bridge
Date: Thu, 4 Oct 2007 14:27:54 -0700
Message-ID: <20071004142754.64827163@freepuppy.rosehill>
References: <20071002141217.GA23610@stilzchen.informatik.tu-chemnitz.de>
	<20071004182738.GA4191@augustus.informatik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mirko.parthey@informatik.tu-chemnitz.de (Mirko Parthey)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58146 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759255AbXJDV2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 17:28:32 -0400
In-Reply-To: <20071004182738.GA4191@augustus.informatik.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 4 Oct 2007 20:27:38 +0200
mirko.parthey@informatik.tu-chemnitz.de (Mirko Parthey) wrote:

> On Tue, Oct 02, 2007 at 04:12:17PM +0200, I wrote:
> > On a machine running Debian testing, I get complete lockups
> > (Num lock LED not responding anymore)
> > 
> > Kernel versions tried (all of them show this problem):
> > - linux-image-2.6.18-5-amd64 (Debian etch)
> > - linux-image-2.6.22-2-amd64 (Debian testing)
> > - plain kernel.org 2.6.23-rc8-git4 (with allmodconfig and ATKBD=y)
> > 
> > The 2.6.18 kernel sometimes prints
> >   Losing some ticks ... checking if CPU frequency changed.
> >   Your time source seems to be instable or some driver is hogging
> >   interrupts.
> >   rip __do_softirq + 0x53/0xd5
> > before freezing.
> 
> I was able to narrow this down a bit - the problem can be reproduced with 
> the ne2k-pci driver alone, sky2 is not needed.
> Powering off isn't necessary, either.
> 
> Hardware preparation:
> - eth0: Compex ReadyLink 2000 (BNC+TP), ne2k-pci driver,
>   network cable disconnected
> 
> How to reproduce the problem:
> 
> brctl addbr br0
> brctl addif br0 eth0
> ifconfig eth0 0 up
> ifconfig br0 192.168.1.17 up
> sync
> find / >/dev/null &
> ping -b 192.168.1.255
> 
> This will lock up my system, usually within a few seconds.
> 
> Some additional information:
> - I could not reproduce the problem when using eth0 directly,
>   without a bridge.
> - Booting with "maxcpus=1" does not help, the problem remains.
>   My system doesn't boot with "nosmp", otherwise I would have
>   tried this too.
>

Yes its a bug, but the ne2k is old crufty device driver not really
suited to bridging. It lacks:
   * proper speed reporting via ethtool (not much of any ethtool support).
   * doesn't report carrier up/down status




-- 
Stephen Hemminger <shemminger@linux-foundation.org>
