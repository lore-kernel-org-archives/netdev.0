From: Dave Jones <davej@redhat.com>
Subject: Re: odd RTL8139 quirk.
Date: Thu, 29 May 2008 11:06:33 -0400
Message-ID: <20080529150633.GA8247@redhat.com>
References: <20080429171403.GA21035@redhat.com> <48177905.4000409@garzik.org> <20080429215626.GC2859@redhat.com> <48179B56.7000606@garzik.org> <20080429153240.7200e1a3.akpm@linux-foundation.org> <4818546C.4060703@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59128 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752889AbYE2PNa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 11:13:30 -0400
Content-Disposition: inline
In-Reply-To: <4818546C.4060703@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 30, 2008 at 07:13:48AM -0400, Jeff Garzik wrote:
 > Andrew Morton wrote:
 > > On Tue, 29 Apr 2008 18:04:06 -0400
 > > Jeff Garzik <jeff@garzik.org> wrote:
 > > 
 > >> Dave Jones wrote:
 > >>> On Tue, Apr 29, 2008 at 03:37:41PM -0400, Jeff Garzik wrote:
 > >>>  > Dave Jones wrote:
 > >>>  > > I've just been playing with a model 2 OQO, which has an RTL8139.
 > >>>  > > It gets detected just fine, though it doesn't actually work..
 > >>>  > > 
 > >>>  > > eth0: RealTek RTL8139 at 0xf8830000, 00:00:00:00:00:00, IRQ 18
 > >>>  > > eth0:  Identified 8139 chip type 'RTL-8139'
 > >>>  > > 
 > >>>  > > The null MAC address being one clue.  Another oddity is that
 > >>>  > > ethtool reports that there's no link detected, even though there is.
 > >>>  > > (Enough for it to PXE boot a kernel from at least :)
 > >>>  > > 
 > >>>  > > Futzing with the debug= modparam didn't yield anything extra at all.
 > >>>  > > 
 > >>>  > > Any clues?
 > >>>  > 
 > >>>  > Sounds like a broken EEPROM.  Does supplying a MAC via ifconfig prior to 
 > >>>  > 'ifconfig ... up' help?
 > >>>
 > >>> Ah. This sounds enlightening: http://www.oqotalk.com/index.php/topic,1511.0.html
 > >>> Seems a shame to have to choose PIO vs MMIO for a distro kernel though.
 > >>> Would there be any objection to turning that into a modparam ?
 > >>> (If we wanted to get really fancy, we could even quirk around it automatically
 > >>>  when we detect broken hardware).
 > >> Something like this?  :)
 > >>
 > >> http://www.linux.sgi.com/archives/netdev/2004-11/msg00226.html
 > >>
 > >> It did not go upstream but it needed some init-time bug fixing, IIRC. 
 > >> Maybe akpm remembers more why my patch sucked... :)
 > > 
 > > Apart from its From: address you mean? ;)
 > > 
 > > I can find no record, sorry.
 > 
 > Yeah, it was in -mm for a while (via netdev-2.6.git#ALL most likely), 
 > and a -mm tester reported that it consistently oops for him, or 
 > something along those lines.
 > 
 > You continually (and rightly!) pestered me about it, and I withdrew the 
 > patch from -mm since I didn't have time to futz with it.

So I got back to looking at this problem yesterday.
Turns out the patch you reference above was merged back in 2005 :-)
See commit 22f714b64b55012fa4e0d77132fa82719180f994

On top of this, it turns out to be really easy to make this a runtime
modparam.  I now have the OQO2 up and running with working ethernet.
Patches to follow.

	Dave

-- 
http://www.codemonkey.org.uk
