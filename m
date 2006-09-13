From: Michael Buesch <mb@bu3sch.de>
Subject: Re: netdev tx timeouts
Date: Wed, 13 Sep 2006 15:49:23 +0200
Message-ID: <200609131549.23764.mb@bu3sch.de>
References: <45076C00.2000100@lwfinger.net> <200609131430.53820.mb@bu3sch.de> <450806D1.4080809@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:3796
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750711AbWIMNuo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 09:50:44 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <450806D1.4080809@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 13 September 2006 15:25, Larry Finger wrote:
> Michael Buesch wrote:
> > On Wednesday 13 September 2006 04:25, Larry Finger wrote:
> >> Michael,
> >>
> >> I still have not gotten a network guru to answer any questions about 
> >> synchronize_net, but I have been testing the patch below:
> > 
> > I'd say this is racy.
> > Did you test this on SMP?
> 
> No - I don't have the hardware.
> > 
> >> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> >> ===================================================================
> >> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> >> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> >> @@ -3169,8 +3169,8 @@ static void bcm43xx_periodic_work_handle
> >>   		 * be preemtible.
> >>   		 */
> >>   		mutex_lock(&bcm->mutex);
> >> -		netif_stop_queue(bcm->net_dev);
> >>   		synchronize_net();
> > 
> > A TX handler starts on another CPU.
> > 
> >> +		netif_stop_queue(bcm->net_dev);
> > 
> > It's still running... boom.
> > 
> 
> I see your point, but the current way breaks a UP system! What to do?

Simple. Reading the code of synchronize_net() and
netif_stop_queue() and thinking about why it breaks, instead
of committing bugfixes that only substitute one bug by another. ;)
I'll take a look, too.

-- 
Greetings Michael.
