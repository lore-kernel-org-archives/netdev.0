From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 15:42:08 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FBF@saturn3.aculab.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com> <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com> <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com> <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com> <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk> <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
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
Received: from mx0.aculab.com ([213.249.233.131]:44750 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756756Ab2HVOoM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 10:44:12 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21823-02 for <netdev@vger.kernel.org>;
 Wed, 22 Aug 2012 15:44:09 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Any patch that exports some "atomic 128-bit MMIO writes" for general
> use sounds totally and utterly broken. You can't do it. It's
> *fundamentally* an operation that many CPU's cannot even do. 64-bit
> buses (or even 32-bit ones) will make the 128-bit write be split up
> *anyway*, regardless of any 128-bit register issues.
> 
> And nobody else sane cares about this, so it shouldn't even be a
> x86-64 specific thing...

There are several other processors that can generate long
PCIe transfers, sometimes by using a DMA engine associated
with the PCIe interface (eg freescale 83xx ppc).

Given the slow speed of PCIe transactions (think ISA bus
speeds - at least with some targets), it is important to
be able to request multi-word transfers in a generic way
on systems that can support it.

This support is a property of the PCIe interface block,
not that of the driver that wishes to use the function.

I don't know if XMM register transfers generate 16byte
TLP on any x86 cpus - they might on some.

Perhaps claiming the function is atomic is the real
problem - otherwise a single TLP could be used on
systems (and in contexts) where it is possible, but
a slower mulit-TLP transfer done (possibly without
guaranteeing the transfer order) done where it is not.

	David
