From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: netdev tx timeouts
Date: Thu, 14 Sep 2006 10:23:37 +0900
Message-ID: <20060914102337.137d4591@localhost.localdomain>
References: <45076C00.2000100@lwfinger.net>
	<200609131430.53820.mb@bu3sch.de>
	<450806D1.4080809@lwfinger.net>
	<200609131549.23764.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53690 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751319AbWINBX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 21:23:57 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609131549.23764.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Sep 2006 15:49:23 +0200
Michael Buesch <mb@bu3sch.de> wrote:

> On Wednesday 13 September 2006 15:25, Larry Finger wrote:
> > Michael Buesch wrote:
> > > On Wednesday 13 September 2006 04:25, Larry Finger wrote:
> > >> Michael,
> > >>
> > >> I still have not gotten a network guru to answer any questions about 
> > >> synchronize_net, but I have been testing the patch below:
> > > 
> > > I'd say this is racy.
> > > Did you test this on SMP?
> > 
> > No - I don't have the hardware.
> > > 
> > >> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> > >> ===================================================================
> > >> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> > >> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> > >> @@ -3169,8 +3169,8 @@ static void bcm43xx_periodic_work_handle
> > >>   		 * be preemtible.
> > >>   		 */
> > >>   		mutex_lock(&bcm->mutex);
> > >> -		netif_stop_queue(bcm->net_dev);
> > >>   		synchronize_net();
> > > 
> > > A TX handler starts on another CPU.
> > > 
> > >> +		netif_stop_queue(bcm->net_dev);
> > > 
> > > It's still running... boom.
> > > 
> > 
> > I see your point, but the current way breaks a UP system! What to do?
> 
> Simple. Reading the code of synchronize_net() and
> netif_stop_queue() and thinking about why it breaks, instead
> of committing bugfixes that only substitute one bug by another. ;)
> I'll take a look, too.

Why are you doing the synchronize_net()? it is meant for RCU.
