From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4: Avoid 'may be used uninitialized' warnings
Date: Thu, 14 May 2015 22:30:12 -0400 (EDT)
Message-ID: <20150514.223012.1808412142637659689.davem@davemloft.net>
References: <20150514231708.13594.13610.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, jackm@dev.mellanox.co.il,
	matanb@mellanox.com, idos@mellanox.com, netdev@vger.kernel.org,
	yishaih@mellanox.com, amirv@mellanox.com,
	linux-kernel@vger.kernel.org, roland@purestorage.com
To: bhelgaas@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150514231708.13594.13610.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Thu, 14 May 2015 18:17:08 -0500

> With a cross-compiler based on gcc-4.9, I see warnings like the following:
> 
>   drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function 'mlx4_SW2HW_CQ_wrapper':
>   drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:3048:10: error: 'cq' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>     cq->mtt = mtt;
> 
> I think the warning is spurious because we only use cq when
> cq_res_start_move_to() returns zero, and it always initializes *cq in that
> case.  The srq case is similar.  But maybe gcc isn't smart enough to figure
> that out.
> 
> Initialize cq and srq explicitly to avoid the warnings.
> 
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

Applied.

The compiler, generally, is not good at determining use-before-initialized
in situations of the form:

	int x;

	if (foo)
		x = whatever;
	...
	if (foo)
		use(x);
