From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] sb1000: prevent a potential NULL pointer dereference in sb1000_dev_ioctl()
Date: Sun, 29 Jul 2007 22:49:13 +0200
Message-ID: <200707292249.13957.mb@bu3sch.de>
References: <200707290002.42722.jesper.juhl@gmail.com> <200707292048.20531.mb@bu3sch.de> <alpine.LFD.0.999.0707300034460.30928@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Domen Puncer <domen@coderock.org>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Steven Hirsch <shirsch@adelphia.net>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49205
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755284AbXG2Ut2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 16:49:28 -0400
In-Reply-To: <alpine.LFD.0.999.0707300034460.30928@enigma.security.iitk.ac.in>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 29 July 2007 21:09, Satyam Sharma wrote:
> Hi Michael,
> 
> 
> On Sun, 29 Jul 2007, Michael Buesch wrote:
> 
> > On Sunday 29 July 2007 20:34:46 Satyam Sharma wrote:
> > > (2) !(dev->flags & IFF_UP) is bogus because the functions of this ioctl
> > > can (and should) be allowed even when the interface is not up and running.
> > 
> > Are you _sure_? This function does poke with the device hardware.
> > It might return crap or even machinecheck when not initialized.
> > Hardware is probably powered down, if not IFF_UP. (I don't know if that's
> > the case here, though).
> 
> IFF_UP checks if the _interface_ is up -- the hardware / card could still
> be powered up, but the interface down (ifconfing eth0 down or ip link set
> eth0 down).

Well, that is device/driver dependent and I don't know what's
the case for this driver. It's encouraged to shutdown hardware
completely (except the WOL parts) when the interface is down.
Dunno if this driver does it. But _if_ it does it, it could cause
problems to poke with the hardware while down.
