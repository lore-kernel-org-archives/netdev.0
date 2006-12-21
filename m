From: Dan Williams <dcbw@redhat.com>
Subject: Re: Network drivers that don't suspend on interface down
Date: Wed, 20 Dec 2006 22:14:08 -0500
Message-ID: <1166670848.23168.21.camel@localhost.localdomain>
References: <20061220042648.GA19814@srcf.ucam.org>
	 <20061220144906.7863bcd3@dxpl.pdx.osdl.net>
	 <20061221011209.GA32625@srcf.ucam.org>
	 <200612202105.31093.flamingice@sourmilk.net>
	 <20061221021832.GA723@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>,
	Stephen Hemminger <shemminger@osdl.org>,
	Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422632AbWLUDMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 22:12:01 -0500
To: Matthew Garrett <mjg59@srcf.ucam.org>
In-Reply-To: <20061221021832.GA723@srcf.ucam.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-21 at 02:18 +0000, Matthew Garrett wrote:
> On Wed, Dec 20, 2006 at 09:05:27PM -0500, Michael Wu wrote:
> 
> > Softmac isn't the only wireless code that likes to be configured after going 
> > up first. Configuring after the card goes up has generally been more 
> > reliable, though that should not be necessary and is a bug IMHO. 
> 
> Ok, that's nice to know. 
> 
> > In order to scan, we need to have the radio on and we need to be able to send 
> > and receive. What are you gonna turn off?
> 
> The obvious route would be to power the card down, but come back up 
> every two minutes to perform a scan, or if userspace explicitly requests 
> one. Would this cause problems in some cases?

Seriously, having all these different capabilities when the card is
"down" is just madness.  Down == Down!!!  Furthermore, every card is
going to support some other subset of capabilities when it's "down".
When you bring "up" prism54 fullmac card, you have to power up the
hardware, reload the firmware, let the firmware boot, and then talk to
it.  Doing that every 2 minutes is just a waste of time, effort, and
power.

If you want to scan, just bring the darn card up to do it.  It's so much
simpler that way, and I just don't see what having all this "every 2
minutes do a scan" policy really buys us.  That doesn't belong in the
kernel.  If something wants to scan, userspace can wake the card up and
do the scan.  It's userspace that's using the scan results to configure
the card anyway, so userspace can do the scan.

Simple == good.  Down == down.  Lets just agree on that and save
ourselves a lot of pain.

Dan


