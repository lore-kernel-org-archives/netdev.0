From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] oops in net_rx_action on 64-bit powerpc
Date: Thu, 23 Oct 2008 17:16:14 -0700 (PDT)
Message-ID: <20081023.171614.72881694.davem@davemloft.net>
References: <4900D794.5020807@nortel.com>
	<F169D4F5E1F1974DBFAFABF47F60C10A069DFCEF@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cfriesen@nortel.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39657
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755179AbYJXAQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 20:16:37 -0400
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A069DFCEF@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Thu, 23 Oct 2008 14:50:06 -0700

> Chris Friesen wrote:
> > I tried booting a post 2.6.27 -git on a Motorola ATCA6101 (very
> > similar to a Maple board).  The first time I booted I got the first
> > log below via the serial console.  I rebooted and got as far as a
> > login prompt.  I was able to log in via the serial console, but then
> > got an almost identical oops again, as shown in the second log below.
> > 
> > I configed out the gigE drivers for the backplane so the only
> > remaining network link was the e100 link used for booting, but the
> > problem remained. 
> > 
> > Anyone have any idea what might be causing this?
> > 
> > Thanks,
> > 
> > Chris
> > 
> > 
> > Starting xinetd: [  OK  ]
> > Starting cron: [  OK  ]
> > Unable to handle kernel paging request for data at address 0x00100108
> 
> that 00100108 pattern looks familiar, I'm not much help here, but I think that had something to do with the list management of the poll_list in a netdev struct.
> 
> so now you just have to figure out why someone's netdev struct is becoming NULL. :-)

Usually this is an indication of returning the wrong value from
the driver's ->poll() routine.

