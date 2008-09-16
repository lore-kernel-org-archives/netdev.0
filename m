From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Subject: Re: [git patches] net driver fixes
Date: Tue, 16 Sep 2008 17:21:48 +0200
Message-ID: <20080916152148.GA7617@alpha.franken.de>
References: <20080916104811.GC7397@cs181140183.pp.htv.fi> <20080916114305.GB10965@ff.dom.local> <20080916121528.GD7397@cs181140183.pp.htv.fi> <20080916135408.GB13388@mit.edu> <20080916070241.3e8d5202@infradead.org> <20080916143408.GA1400@cs181140183.pp.htv.fi> <20080916074802.200c8a43@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@kernel.org>, Theodore Tso <tytso@mit.edu>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:35186 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844AbYIPPWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 11:22:04 -0400
Content-Disposition: inline
In-Reply-To: <20080916074802.200c8a43@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2008 at 07:48:02AM -0700, Arjan van de Ven wrote:
> not sure; just we need to catch doing pci_disable_device on a
> non-enabled device as a WARN_ON.

the pci_disable_device() is done on an enabled device, so your
new WARN_ON wouldn't trigger.

> and the patch looks quite wrong, the real answer should be to do the
> enable in open() :-)

I thought about the solution, but the pci device is completely setup
and enabled in the init function so disabling it at that point and
enabling it in open() again sounds silly to me. pci_enable_enable/disable
is already done in .init/.remove and .suspend/.resume, so it looked
more obviuos to not let close() do the pci_disable_device().

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]
