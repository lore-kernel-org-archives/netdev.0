From: Holger Eitzenberger <holger@my-eitzenberger.de>
Subject: Re: sky2 bonding problem, 802.3ad
Date: Fri, 16 Feb 2007 10:15:59 +0100
Message-ID: <877iuitqcw.fsf@kruemel.my-eitzenberger.de>
References: <871wkruu6p.fsf@kruemel.my-eitzenberger.de>
	<200702152013.l1FKDE22017473@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org,
	sk-drivers@lists.linux-foundation.org, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:49672 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423447AbXBPJSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 04:18:11 -0500
In-Reply-To: <200702152013.l1FKDE22017473@death.nxdomain.ibm.com> (Jay
 Vosburgh's message of "Thu, 15 Feb 2007 12:13:14 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh <fubar@us.ibm.com> writes:

> 	The log you included (with debug turned on) indicates that
> bonding is at least attempting to send LACPDUs, but there are no log
> entries for having received any LACPDUs.

Yes, the log clearly shows that the LACPDUs are sent, at least bonding
thinks so.  I just checked for received mcast packages on the switch:
yes, they come in frequently on all four ports.  Though I can't check or
Slow_Protocols_Multicast address specifically.

> 	If the switch is configured, you may want to also check to see
> if it has counters for LACPDUs sent and received.  If the switch is not
> sending and receiving LACPDUs on the appropriate ports, then it's more
> likely to be a communications problem somewhere (vs. an 802.3ad
> negotiation problem).

I did not find a dedicated stat for received LACPDUs.

I tried some settings on the switch webinterface.  Interesting: if I
toggle the 'Admin Flow Control' from either 'enabled' to
'autonegotiation' I immediately receive the switch LACPCUs, see:

 bonding: ad_tx_machine() 1210: Sent LACPDU on port 1
 bonding: bond_3ad_rx_indication() 2175: Received LACPDU on port 1
 bonding: ad_rx_machine() 1123: Rx Machine: Port=1, Last State=6, Curr
   State=6

If I then disable the bond (rmmod inclusive) and then enable the bond
again there are no received LACPDUs from the switch.  Mmmpff...

> 	For the version of bonding in your dmesg log, the IFF_NOARP is
> expected; 802.3ad will select one aggregator as the active one, the
> other aggregators will be marked inactive, and that sets IFF_NOARP.
> Since no LACPDUs have been exchanged, bonding is leaving each interface
> as a separate aggregator.  Versions of bonding later than February 2006
> (your proc-bond0-ok for example) don't set the IFF_NOARP on inactive
> slaves (a new mechanism is used that doesn't mess with the flags).

Yes, I already saw in the code that IFF_NOARP was expected.

Any ideas?

  /holger
