From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Can someone please try...
Date: Wed, 24 Jan 2007 09:43:24 +0100
Message-ID: <200701240943.24141.mb@bu3sch.de>
References: <200701161806.02780.mb@bu3sch.de> <200701231021.34995.mb@bu3sch.de> <1169617390.30511.27.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
To: Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:54136
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965448AbXAXIon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 03:44:43 -0500
In-Reply-To: <1169617390.30511.27.camel@dv>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 24 January 2007 06:43, Pavel Roskin wrote:
> On Tue, 2007-01-23 at 10:21 +0100, Michael Buesch wrote:
> > On Tuesday 23 January 2007 07:14, Pavel Roskin wrote:
> > > I have tried the patch, and it doesn't fix the problem.  It's a separate
> > > problem.  It happens when bcm43xx_interrupt_handler() is called on a
> > > device that has already been removed.
> > 
> > That shouldn't happen and doesn't for me.
> > 
> > > It looks like 
> > > bcm43xx_wireless_core_stop() should be called from
> > > bcm43xx_one_core_detach().
> > 
> > No, well... . remove_interface should have been called by the stack, no?
> 
> It is not.  It's called if I bring the interface down with ifconfig.  If
> I remove live interface with "rmmod bcm43xx_d80211",
> bcm43xx_one_core_detach() is called first, followed by kernel panic in 
> bcm43xx_interrupt_handler().
> 
> And that's what I see in the code.  Module removal calls bcm43xx_exit().
> It unregisters the ssb driver first.  The ssb layer calls
> bcm43xx_remove(), which calls bcm43xx_one_core_detach() before doing
> anything with the wireless stack or with interrupts.
> 
> I tried to put bcm43xx_one_core_detach() to the end of bcm43xx_remove(),
> but the result was the same.  Still, I think the solution lies in that
> direction.  We should stop the hardware before dismantling any data
> structures.

Ok, I see. I will try to debug this.

-- 
Greetings Michael.
