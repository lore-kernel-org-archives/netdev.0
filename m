From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 0/16] DMA-API debugging facility v2
Date: Fri, 6 Feb 2009 10:20:52 -0800
Message-ID: <20090206182052.GI27684@sequoia.sous-sol.org>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1233874352.8135.12.camel@macbook.infradead.org> <20090206020535.GE27684@sequoia.sous-sol.org> <1233907006.17724.83.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Wright <chrisw@sous-sol.org>,
	Joerg Roedel <joerg.roedel@amd.com>,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org, mingo@redhat.com,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:59348 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752730AbZBFSVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 13:21:30 -0500
Content-Disposition: inline
In-Reply-To: <1233907006.17724.83.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Woodhouse (dwmw2@infradead.org) wrote:
> An alternative explanation... The DMA is aborted=B9, and the device
> interrupts us to tell us about it at the _same_ time that the IOMMU
> interrupts us to tell us about the fault. We process the device
> interrupt first, unmap that buffer. And then we process the IOMMU
> interrupt... and the buffer is already gone from the list.

[  362.283661] Device 0000:03:00.0 mapping: 1000@fff1b000
[  362.283727] DMAR:[DMA Write] Request device [03:00.0] fault addr fff=
1b000=20
[  362.284719] Device 0000:03:00.0 unmapping: 1000@fff1b000

[  362.426974] Device 0000:03:00.0 mapping: 1000@fff1b000
[  362.427040] DMAR:[DMA Write] Request device [03:00.0] fault addr fff=
1b000=20
[  362.429092] Device 0000:03:00.0 unmapping: 1000@fff1b000

[  447.644332] Device 0000:03:00.0 mapping: 1000@fff03000
[  447.644373] DMAR:[DMA Write] Request device [03:00.0] fault addr fff=
03000=20
[  447.646008] Device 0000:03:00.0 unmapping: 1000@fff03000

[  483.037641] Device 0000:03:00.0 mapping: 1000@ffc9f000
[  483.037707] DMAR:[DMA Write] Request device [03:00.0] fault addr ffc=
9f000=20
[  483.038699] Device 0000:03:00.0 unmapping: 1000@ffc9f000

=2E..

Looks like driver is doing the right thing.
