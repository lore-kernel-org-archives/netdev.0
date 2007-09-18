From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: e1000 driver and samba
Date: 18 Sep 2007 09:45:07 +0200
Message-ID: <ygfps0g8lj0.fsf@janus.isnogud.escape.de>
References: <780b6f780709171158h1016b6c2kfbc977b4ea7c715c@mail.gmail.com>
	<36D9DB17C6DE9E40B059440DB8D95F5203592D77@orsmsx418.amr.corp.intel.com>
	<20070918020358.d50653d5.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"L F" <lfabio.linux@gmail.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"James Chapman" <jchapman@katalix.com>, <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:46703 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753890AbXIRHua (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 03:50:30 -0400
In-Reply-To: <20070918020358.d50653d5.billfink@mindspring.com>; from Bill Fink on Tue, 18 Sep 2007 02:03:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Fink <billfink@mindspring.com> writes:

> It may also be a useful test to disable hardware TSO support
> via "ethtool -K ethX tso off".

All suggestions here on the list, i.e. checking for flow control,
duplex, cable problems, etc. don't explain (at least to me) why LF
sees file corruption.  How can a corrupted frame pass the TCP checksum
check?  Does TCP use the hardware checksum of the NIC if available?
AFAICS, this would be the only way for a corrupt frame to make it into
the file.  But Bill already suggested this and LF reported that it
didn't make a difference.

A few months ago I had hadware problems with an embedded device, where
transmission from the NIC via the PCI bus to the CPU had some bits
flipped.  But tcpdump clearly showed the TCP checksum errors and also
TCP recognized the errors and the connection was stalled.  And, BTW,
we also observed an increasing percentage of corrupted frames with
increasing traffic on that interface, i.e. increasing load on the PCI
bus.

So I would run tcpdump -s0 and watch for "incorrect checksum" messages.


urs
