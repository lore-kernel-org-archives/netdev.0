From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC] HOWTO use NAPI to reduce TX interrupts
Date: Mon, 21 Aug 2006 17:29:05 -0700
Message-ID: <adaac5x3966.fsf@cisco.com>
References: <44E7BB7F.7030204@osdl.org> <200608191325.19557.arnd@arndb.de>
	<20060821235244.GJ5427@austin.ibm.com>
	<20060821.165616.107936004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linas@austin.ibm.com, arnd@arndb.de, shemminger@osdl.org,
	akpm@osdl.org, netdev@vger.kernel.org, jklewis@us.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Jens.Osterkamp@de.ibm.com, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:29779 "EHLO
	sj-iport-1.cisco.com") by vger.kernel.org with ESMTP
	id S1751309AbWHVA3J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 20:29:09 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060821.165616.107936004.davem@davemloft.net> (David Miller's message of "Mon, 21 Aug 2006 16:56:16 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    David> Don't touch interrupts until both RX and TX queue work is
    David> fullydepleted.  You seem to have this notion that RX and TX
    David> interrupts are seperate.  They aren't, even if your device
    David> can generate those events individually.  Whatever interrupt
    David> you get, you shut down all interrupt sources and schedule
    David> the ->poll().  Then ->poll() does something like:

This is a digression from spidernet, but what if a device is able to
generate separate MSIs for TX and RX?  Some people from IBM have
suggested that it is beneficial for throughput to handle TX work and
RX work for IP-over-InfiniBand in parallel on separate CPUs, and
handling everything through the ->poll() method would defeat this.

 - R.
