From: Bill Fink <billfink@mindspring.com>
Subject: Re: e1000 driver and samba
Date: Sat, 15 Sep 2007 01:09:16 -0400
Message-ID: <20070915010916.d8bd035d.billfink@mindspring.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
	<46EAC25B.2060404@intel.com>
	<780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>
	<46EAF644.1040006@intel.com>
	<780b6f780709141737w4e17f0a8r944555f27f7344dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
To: "L F" <lfabio.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:50053 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750716AbXIOFJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2007 01:09:29 -0400
In-Reply-To: <780b6f780709141737w4e17f0a8r944555f27f7344dd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Sep 2007, L F wrote:

> > can you describe your setup a bit more in detail? you're writing from a linux
> > client to a windows smb server? or even to a linux server? which end sees the
> > connection drop? the samba server? the samba linux client?
> Certainly.
> I have a LAN, with two switches in a stack. There currently are 7
> WinXP clients and one linux machine. The linux machine acts as a samba
> server and as a firewall/gateway.
> The two ports of the PRO/1000 in the linux box are connected to the
> LAN (eth4) and to a Comcast modem (eth3) respectively. Shorewall 3.4.5
> is running on the linux machine, with a strong firewall + NAT setup.
> Further, the linux machine currently has a tap device bridged into the
> LAN side, for virtualbox.
> Therefore, eth3 is a plain ethernet interface. br0, on the lan side,
> is tap0 + eth4.
> If I get any client on the LAN side, I can read from the linux box
> without a problem. However, if I attempt to write to the linux box
> from a LANside client, it will fail. If traffic is low, the failures
> are sporadic. If traffic is high (large file and/or multiple incoming
> files) the failure is guaranteed, either in 'delayed write fail' mode
> on the client or in silent corruption of the file (much worse). If
> read/write activity is combined, for instance when I unzip a zip
> archive to its own directory, failure is guaranteed and rapid, with a
> 'delayed write fail' on the client after 50MB or so.
> I can post .config and anything else you may want if you require it. I
> tried changing cable as you suggested with little success. I'll try
> changing switch port, just to cover all bases.

Would it be worth a shot to try disabling the receiver hardware
checksumming (ethtool -K ethX rx off)?

						-Bill
