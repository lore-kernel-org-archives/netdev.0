From: Andi Kleen <andi@firstfloor.org>
Subject: Re: netconsole system freeze when cable unplugged
Date: 10 Mar 2007 14:38:23 +0100
Message-ID: <p73r6rx9q28.fsf@bingen.suse.de>
References: <45F1B6FD.1060902@simon.arlott.org.uk>
	<20070309204243.GA28441@electric-eye.fr.zoreil.com>
	<45F1EE12.2070605@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55313 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752822AbXCJMjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2007 07:39:11 -0500
In-Reply-To: <45F1EE12.2070605@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Arlott <simon@fire.lp0.eu> writes:

> On 09/03/07 20:42, Francois Romieu wrote:
> > Simon Arlott <simon@fire.lp0.eu> :
> >> When I unplug the cable the system just stops responding to
> >> anything, at all. No message is printed to the console when the
> >> cable is plugged back in.
> > rtl8139_interrupt (spin_lock(&tp->lock))
> > -> rtl8139_weird_interrupt
> >    -> rtl_check_media
> >       -> mii_check_media (printk(KERN_INFO "%s: link down\n", ...))
> >          [netpoll stuff here]
> >          -> rtl8139_poll_controller
> >             -> rtl8139_interrupt
> >                *deadlock*
> > See below for my random stuff of the day. Feel free to open a PR at
> > bugzilla.kernel.org if the issue does not go away.
> 
> The patch doesn't fix it, nothing changes. I'm not sure how this can
> be debugged if printk won't work...

earlyprintk can be called directly (early_printk()) and should
work. It won't log over the network of course.

-Andi
