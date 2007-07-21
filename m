From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Linux, tcpdump and vlan
Date: Sat, 21 Jul 2007 13:32:31 +0200
Message-ID: <m3sl7idmb4.fsf@maximus.localdomain>
References: <997818.30021.qm@web56615.mail.re3.yahoo.com>
	<m31wf226fw.fsf@maximus.localdomain>
	<46A11C54.2090100@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andrei radulescu-banu <iubica2@yahoo.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:55718 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761342AbXGULce (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2007 07:32:34 -0400
In-Reply-To: <46A11C54.2090100@candelatech.com> (Ben Greear's message of "Fri, 20 Jul 2007 13:34:28 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> writes:

> There is already a flag you can set on vlan devices (reorder-header)
> that strips the VLAN tag before presenting it to user-space.

Sure, but isn't it only valid for VLAN device (not the main ethX)?
I.e., can you have the tag stripped from frames captured on ethX?

> On tx, if it shows up on the vlan device, we add that device's VID to
> the header if no VID is currently in the SKB.  If it is in the SKB header
> we change the VID to be the tx dev's VID (if it was different).  This allows user-space
> to send a raw ethernet frame on a vlan device and have it automatically
> go out of the box on the correct vlan.  User-space can also send raw VLAN frames
> and have those also go out on the correct VLAN.

Well... I think the tag should be added unconditionally (for things like
QinQ) but that's trivial and minor.

IOW: I think all Ethernet interfaces should always be VLAN-aware,
stripping the tag (only one) early on RX and adding it late on TX.
That means tcpdump would see packets with exactly one tag removed
(unless there was no tag), in both RX and TX.

Tcpdump would need other means to get VLAN id...
-- 
Krzysztof Halasa
