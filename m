From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 16:05:03 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FC0@saturn3.aculab.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com> <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com> <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com> <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com> <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk> <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com> <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk> <CA+55aFxoWLad9vtfAzQ7qXWcspL92D5s5+MFJ-HfyH3LVqfpaA@mail.gmail.com> <CA+55aFzQDx78qBgDQyb6LuSyAyi_m=y8XjyRWf1J4kb0399U5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	"David Miller" <davem@davemloft.net>, <tglx@linutronix.de>,
	<mingo@redhat.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <x86@kernel.org>
To: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45125 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932728Ab2HVPGe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 11:06:34 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21800-09 for <netdev@vger.kernel.org>;
 Wed, 22 Aug 2012 16:06:32 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <CA+55aFzQDx78qBgDQyb6LuSyAyi_m=y8XjyRWf1J4kb0399U5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Btw, are we even certain that a 128-bit PCIe write is going to remain
> atomic across a bus (ie over various PCIe bridges etc)? Do you you
> care? Is it just a "one transaction is cheaper than two", and it
> doesn't really have any ordering constraints? If the thing gets split
> into two 64-bit transactions (in whatever order) by a bridge on the
> way, would that be ok?

PCIe transfers are basically hdlc packets containing the address,
command and any associated data. Unless they get bridged
though some strange PCIe<->PCI<->PCIe system they are very
unlikely to get broken up.
Maybe if they are longer than the maximum TLP size for the
target somewhere - but that is probably at least 128 bytes.

The time taken is largely independent of the transfer size.
The systems I've used (ppc accessing an Altera FPGA) have
PCIe cycles types of the order of microseconds.
Even for slow comms it is important to generate long TLP.

	David
