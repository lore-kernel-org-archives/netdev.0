From: Bill Fink <billfink@mindspring.com>
Subject: Re: e1000 driver and samba
Date: Tue, 18 Sep 2007 02:03:58 -0400
Message-ID: <20070918020358.d50653d5.billfink@mindspring.com>
References: <780b6f780709171158h1016b6c2kfbc977b4ea7c715c@mail.gmail.com>
	<36D9DB17C6DE9E40B059440DB8D95F5203592D77@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "L F" <lfabio.linux@gmail.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"James Chapman" <jchapman@katalix.com>, <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:49597 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753651AbXIRGEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 02:04:13 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5203592D77@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Sep 2007, Brandeburg, Jesse wrote:

> L F wrote:
> > On 9/17/07, Kok, Auke <auke-jan.h.kok@intel.com> wrote:
> >> The statistic we were looking at _will_ increase when running in
> >> half duplex, but if it increases when running in full duplex might
> >> indicate a hardware failure. Probably you have fixed the issue with
> >> the CAT6 cable. 
> > Uhm, 'fixed' may be premature: I restarted the machine and with 22
> > hours uptime I am getting:
> > tx_deferred_ok: 36254
> > 
> >> Can you run this new configuration with the old cable? that would
> >> eliminate the cable (or not)
> > I most certainly can. This seems to have gotten worse by a factor or
> > 100 or more.. so am I to suspect the new cable?
> > 
> >> A single port failure on a switch can also happen, and samba is
> >> definately 
> >> a good test for defective hardware. I cannot rule out anything from
> >> the information we have gotten yet.
> > True, but I tried changing the switch ports with little change.
> > Putting a client on the same switch port yielded no errors on the
> > client, although unfortunately I don't have ethtool statistics on XP.
> > The switch, btw, is a fairly generic GS108 from Netgear (there
> > actually are two).
> 
> it may be not well documented, but the hardware has several states that
> it can get into that can cause tx_deferred counter to increment.  None
> of them are fatal to traffic, it is mainly an informational statistic.
> 
> in this case it is in the "due to receiving flow control; tx is paused"
> state...
> 
> he has 488 rx flow control xoff/xon, which means the switch is being
> overloaded and sending flow control, or the switch is passing through
> flow control packets (which it should not since they are multicast) and
> (some) client is overloaded.
> 
> can you turn off flow control at the server?  ethtool -A ethX rx off tx
> off or load the driver with parameter FlowControl=0  With the 7.6.5
> driver at least you'll get confirmation of the flow control change on
> the "Link Up:" line.

It may also be a useful test to disable hardware TSO support
via "ethtool -K ethX tso off".

						-Bill
