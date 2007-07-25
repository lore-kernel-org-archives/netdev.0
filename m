From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: 2.6.23-rc1 sky2 boot crash in sky2_mac_intr
Date: Wed, 25 Jul 2007 11:27:52 +0100
Message-ID: <20070725112752.11d21751@oldman.hamilton.local>
References: <20070724082205.GA19480@paradigm.rfc822.org>
	<20070724095008.0eb154fe@oldman.hamilton.local>
	<20070724094042.GA6414@paradigm.rfc822.org>
	<6bffcb0e0707241630p3599ad99sfd778097b307e78c@mail.gmail.com>
	<20070725072202.GA4905@paradigm.rfc822.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Lohoff <flo@rfc822.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41515 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756473AbXGYK14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 06:27:56 -0400
In-Reply-To: <20070725072202.GA4905@paradigm.rfc822.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Jul 2007 09:22:02 +0200
Florian Lohoff <flo@rfc822.org> wrote:

> On Wed, Jul 25, 2007 at 01:30:31AM +0200, Michal Piotrowski wrote:
> > >I'll try the above and keep you posted. The crash itself seems to be a
> > >2.6.23-rc1 regression though. I never experienced this with 2.6.22-rc5
> > >which i was running before.
> > 
> > Can you try to figure out what is causing this crash and then use 
> > git-bisect?
> 
> Are there so many changes between 2.6.22-rc5 and 2.6.23-rc1 for the sky2?
> 
> As the crash is not that reproducible, just occasionally on boot i guess
> bisecting is more or less waste of time.
> 
> Flo
> -- 
> Florian Lohoff                  flo@rfc822.org             +49-171-2280134
> 	Those who would give up a little freedom to get a little 
>           security shall soon have neither - Benjamin Franklin

I would suspect these as possible causes of the regression was one of these
patches.

commit 8f70920f2f2a699b4ad35e625071cd92f4ba6ca3
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Mon Jun 4 17:23:25 2007 -0700

    sky2: GPIO register
    
    The General Purpose I/O register is yet another hardware workaround
    catchall. Enable workaround that vendor driver does to stay
    but for bug compatiable.
    
    Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 451af33552286b426940a32126bd3ece243223a3
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Mon Jun 4 17:23:24 2007 -0700

    sky2: enable clocks before probe
    
    Catch-22: On Yukon EX (88E8071) need to have internal clocks enabled
    before reading chip id. It is harmless on other chips.
    
    Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit fc99fe0618f355b708ce88fedaca9783072ac3d5
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Mon Jun 4 17:23:22 2007 -0700

    sky2: Add PCI device specfic register 4 & 5
    
    Need to setup more PCI control control registers are on Yukon EX.
    Some of these also exist on Yukon EC-U as well.
    
    Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

