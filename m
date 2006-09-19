From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 12/23] e1000: Maybe stop TX if not enough free
 descriptors
Date: Tue, 19 Sep 2006 16:59:23 -0700
Message-ID: <20060919165923.1c0073d9@localhost.localdomain>
References: <20060919172623.4605.56860.stgit@gitlost.site>
	<20060919172859.4605.60855.stgit@gitlost.site>
	<45104719.9080708@pobox.com>
	<20060919125019.316d3790@localhost.localdomain>
	<451056D2.4080909@pobox.com>
	<20060919135910.1afb7f24@localhost.localdomain>
	<45107C94.9020503@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20968 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751043AbWISX77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 19:59:59 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <45107C94.9020503@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Sep 2006 16:26:12 -0700
Auke Kok <auke-jan.h.kok@intel.com> wrote:

> Stephen Hemminger wrote:
> > On Tue, 19 Sep 2006 16:45:06 -0400
> > Jeff Garzik <jgarzik@pobox.com> wrote:
> > 
> >> looks OK except for the tasklet, which may starve if the lock is being 
> >> held upon entry
> >>
> >>
> > 
> > Why would the tasklet starve anymore than NAPI?
> > Worst case, the transmitters fill the ring completely and have to
> > wait for the tasklet to clean up.
> > 
> > Maybe it would be better to always to Tx cleanup in tasklet even with
> > NAPI. Then the NAPI poll flow control would be used only for Rx.
> > As it stands, if receiver gets swamped, the poll doesn't get run often,
> > so the transmitter cleanup doesn't get run. A tasklet has the advantage
> > of eliminating the need for adapter->tx_queue_lock as well.
> 
> I gave it a spin and it looks horrible with NAPI - the box almost freezes up 
> with even 2 clients. Minor nitpick: you forgot to delete a spin_lock_irqsave() 
> call but gcc would have spotted that for you. Unsurprisingly it's more stable 
> without NAPI.
> 
> I'm unsure (not enough knowlege) why you would prefer to remove lltx - care to 
> enlighten me?

It is just that bouncing in and out of the driver to do spin lock attempts is
awkward. I don't think the implementation of LLTX was meant for devices that
lock, more for software devices like loopback.

The patch was more of an experiment to see if there was a simpler way.
