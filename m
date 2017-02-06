From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2017-02-06,pull-request: can-next
 2017-02-06
Date: Mon, 06 Feb 2017 11:12:59 -0500 (EST)
Message-ID: <20170206.111259.2261971436931731059.davem@davemloft.net>
References: <2b600a5b-f928-fe73-5b30-8b2fc1398068@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
        linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <2b600a5b-f928-fe73-5b30-8b2fc1398068@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 6 Feb 2017 15:50:48 +0100

> this is a pull request of 16 patches for net-next/master.
> 
> The first two patches by David Jander and me add the rx-offload
> framework for CAN devices to the kernel. The remaining 14 patches
> convert the flexcan driver to make use of it.

Pulled, but I wonder if your comparisons does the right thing when the
counters overflow.

I think you need to do the same thing we do for TCP sequence number
comparisons and code it like:

static inline bool before(__u32 seq1, __u32 seq2)
{
        return (__s32)(seq1-seq2) < 0;
}
