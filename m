From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Sun, 20 May 2012 12:41:14 -0400
Message-ID: <20120520164114.GD21177@windriver.com>
References: <1337362769-4676-1-git-send-email-paul.gortmaker@windriver.com>
 <201205182016.51489.linux@rainbow-software.org>
 <20120518220305.GC15256@windriver.com>
 <201205191058.45328.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Alan Cox <alan@linux.intel.com>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50804 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049Ab2ETQl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2012 12:41:29 -0400
Content-Disposition: inline
In-Reply-To: <201205191058.45328.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.] On 19/05/2012 (Sat 10:58) Ondrej Zary wrote:

> On Saturday 19 May 2012 00:03:06 Paul Gortmaker wrote:
> > [Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.] On 
> 18/05/2012 (Fri 20:16) Ondrej Zary wrote:
> > > On Friday 18 May 2012 19:39:29 Paul Gortmaker wrote:
> > > > It was amusing that linux was able to make use of this 1980's
> > > > technology on machines long past its intended lifespan, but
> > > > it probably should go now -- it is causing issues in some
> > > > distros[1], and while that might be fixable, it is just not
> > > > worth it.
> > > >
> > > > [1]
> > > > http://www.linuxquestions.org/questions/linux-networking-3/3com-3c501-c
> > > >ard- not-detecting-934344/
> > >
> > > That looks like a bug elsewhere and removing this driver will not fix it.
> >
> > You miss the point.  We've got someone with a modern i7 machine who is
> > getting confused by seeing messages from some ancient 3c501 driver, but
> > he doesn't have the context to know it is ancient and the message is a
> > red herring.  Will it fix a distro's broken init that tries to modprobe
> > everything?  No.  Will it help by not muddying the waters with
> > meaningless printk from 3c501 that confuse users?  Yes.
> 
> Are you going to remove all drivers that complain that the HW is not present 
> because some broken script is trying to modprobe them all? Or only the first 
> one? 3c501 is probably the first in alphabet. You remove that and the script 
> will modprobe 3c503 then...

Per my other mail, I think to focus on this one user's issue misses the
bigger picture entirely; the real issue was called out in the commit log:

   But from a functional point of view, the real issue, as stated
   in the (also obsolete) Ethernet-HowTo, is that "...the 3c501 can
   only do one thing at a time -- while you are removing one packet
   from the single-packet buffer it cannot receive another packet,
   nor can it receive a packet while loading a transmit packet."
   
Regardless, to answer your questions:

1) No, obviously an rm-rf of all drivers that can't probe quietly was 
not going to happen; that was never implicilty or explicitly proposed.

2) From memory while working on the 3c503 driver 15 odd years ago, it
could probe silently and semi reliably, which was impressive then, given
it was pre ISA-PnP.  It was worlds ahead of a 3c501 card.

Paul.
--

> 
> -- 
> Ondrej Zary
