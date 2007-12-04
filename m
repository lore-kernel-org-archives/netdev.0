From: Matt Mathis <mathis@psc.edu>
Subject: Re: e1000 driver problems
Date: Tue, 4 Dec 2007 11:02:23 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0712041043520.15251@tesla.psc.edu>
References: <20071120143803.GA5638@ics.muni.cz> <474B5610.4030800@intel.com>
 <20071127150700.GB4365@ics.muni.cz> <474C4A74.90705@intel.com>
 <20071127173146.GG4365@ics.muni.cz> <474C5678.3060609@intel.com>
 <20071127174456.GH4365@ics.muni.cz> <474C6084.9000301@intel.com>
 <20071203095023.GG26573@ics.muni.cz> <47541ED0.9090808@intel.com>
 <20071204153405.GG8704@ics.muni.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: NetDev <netdev@vger.kernel.org>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:63087 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753559AbXLDQWf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 11:22:35 -0500
In-Reply-To: <20071204153405.GG8704@ics.muni.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is probably not an e1000 problem, but a general Ethernet "feature".  If 
you defeat auto-negotiation to force the data rate, you implicitly defeat 
duplex negotiation as well.  You need to explicitly set the duplex mode.

In full duplex mode, send and receive are are fully independent, and packets
can flow concurrently in both directions.

In half duplex mode the receiver assumes it is hearing its own transmission, 
and ignores (or errors) frames that are partially overlapped by it's 
own transmission.

See for example: S. Shalunov and R. Carlson. "Detecting Duplex Mismatch on 
Ethernet"
http://www.springerlink.com/content/vapet12x584e6wyn/

Best regards,
--MM--

On Tue, 4 Dec 2007, Lukas Hejtmanek wrote:

> Another problem at my own machine. If I force speed to 100Mb on 1GE network,
> I can reach 95Mbps bidirectional using UDP (0.34% loses) but only 1.2Mbps
> using TCP. A bug? If I enable autonegotiation and run at 1GE, I can got 95Mb
> on TCP to the target machine (the target machine has only 100Mb connection).
>
