From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: E1000: bug on error path in e1000_probe()
Date: Tue, 01 Aug 2006 11:54:58 -0700
Message-ID: <44CFA382.7040703@intel.com>
References: <Pine.LNX.4.64.0607311522200.3139@madrid.max-t.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Cramer, Jeb J" <jeb.j.cramer@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59144 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1751791AbWHAS4B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 14:56:01 -0400
To: Stephane Doyon <sdoyon@max-t.com>
In-Reply-To: <Pine.LNX.4.64.0607311522200.3139@madrid.max-t.internal>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephane Doyon wrote:
> The e1000_probe() function passes references to the netdev structure 
> before it's actually registered. In the (admittedly obscure) case where 
> the netdev registration fails, we are left with a dangling reference.
> 
> Specifically, e1000_probe() calls
>         netif_carrier_off(netdev);
> before register_netdev(netdev).
> 
> (It also calls pci_set_drvdata(pdev, netdev) rather early, not sure how 
> important that is.)
> 
> netif_carrier_off() does linkwatch_fire_event(dev);, which in turn does 
> dev_hold(dev); and queues up an event with a reference to the netdev.
> 
> But the net_device reference counting mechanism only works on registered 
> netdevs.
> 
> Should the register_netdev() call fail, the error path does 
> free_netdev(netdev);, and when the event goes off, it accesses random 
> memory through the dangling reference.
> 
> I would recommend moving the register_netdev() call earlier.

We agree that this may be an issue and we're looking at how this mis-ordering 
entered the code in the first place. I'm probably going to send a patch later 
today or include it in this week-worths upstream patches later this week.

We were wondering however how you encountered this problem? Did you see a case 
where this race actually happened? it might be an interesting case to look at. 
Or did you do this by code review only?

Auke
