From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 driver problems
Date: Tue, 04 Dec 2007 09:19:11 -0800
Message-ID: <47558C0F.9000708@intel.com>
References: <20071127150700.GB4365@ics.muni.cz> <474C4A74.90705@intel.com> <20071127173146.GG4365@ics.muni.cz> <474C5678.3060609@intel.com> <20071127174456.GH4365@ics.muni.cz> <474C6084.9000301@intel.com> <20071203095023.GG26573@ics.muni.cz> <47541ED0.9090808@intel.com> <20071204153405.GG8704@ics.muni.cz> <Pine.LNX.4.64.0712041043520.15251@tesla.psc.edu> <20071204170827.GH8704@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Matt Mathis <mathis@psc.edu>, NetDev <netdev@vger.kernel.org>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59888 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751075AbXLDRTw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 12:19:52 -0500
In-Reply-To: <20071204170827.GH8704@ics.muni.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lukas Hejtmanek wrote:
> On Tue, Dec 04, 2007 at 11:02:23AM -0500, Matt Mathis wrote:
>> This is probably not an e1000 problem, but a general Ethernet "feature".  
>> If you defeat auto-negotiation to force the data rate, you implicitly 
>> defeat duplex negotiation as well.  You need to explicitly set the duplex 
>> mode.
> 
> ethtool reports, that I have full duplex line:

Matt was almost right - the link partner however might be working in half duplex
mode. in case you force speed/duplex, you are *required* to force the exact same
setting on the link partner, otherwise things like this can happen.

if you "just" want to disable gigabit speed, get the latest ethtool and run:

   ethtool -s eth0 advertise 0x0f

which keeps autonegotiation enabled but tells the e1000 card to _not_ advertise
gigabit speed capability to the link partner. The link partner and the e1000 can
then decide with autonegotiation whether to use 10half 10duplex 100half or 100full.

Auke
