From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Mon, 30 Nov 2015 11:25:00 -0500 (EST)
Message-ID: <20151130.112500.293198684175670933.davem@redhat.com>
References: <CAPv3WKc4zSmjtw_FeePCVCaq_aUubbCw_ggtxgxs0-7LwL7fHQ@mail.gmail.com>
	<20151129.210210.1777978635596463961.davem@davemloft.net>
	<CAPv3WKcHnJHCvg63Vs79RboNOuESU8jCLouKPRW4NdptAd_hag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
	linux@arm.linux.org.uk, jason@lakedaemon.net, myair@marvell.com,
	jaz@semihalf.com, simon.guinot@sequanux.org, xswang@marvell.com,
	nadavh@marvell.com, alior@marvell.com, tn@semihalf.com,
	gregory.clement@free-electrons.com, nitroshift@yahoo.com,
	sebastian.hesselbarth@gmail.com
To: mw@semihalf.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPv3WKcHnJHCvg63Vs79RboNOuESU8jCLouKPRW4NdptAd_hag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcin Wojtas <mw@semihalf.com>
Date: Mon, 30 Nov 2015 15:13:22 +0100

> What kind of abstraction and helpers do you mean? Some kind of API
> (e.g. bm_alloc_buffer, bm_initialize_ring bm_put_buffer,
> bm_get_buffer), which would be used by platform drivers (and specific
> aplications if one wants to develop on top of the kernel)?
> 
> In general, what is your top-view of such solution and its cooperation
> with the drivers?

The tricky parts involved have to do with allocating pages for the
buffer pools and minimizing the number of atomic refcounting
operations on those pages for for the puts and gets, particularly
around buffer replenish runs.

For example, if you're allocating a page for a buffer pool the device
will chop into N (for any N < PAGE_SIZE) byte pieces, you can
eliminate many atomic operations.
