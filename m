From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smc91c92_cs : add a spinlock to avoid race condition
Date: Thu, 18 Aug 2016 21:07:34 -0700 (PDT)
Message-ID: <20160818.210734.1003452853595787957.davem@davemloft.net>
References: <1471354746-27110-1-git-send-email-andrianov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, a@unstable.cc, felipe.balbi@linux.intel.com,
        fw@strlen.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        vaishali.thakkar@oracle.com, ldv-project@linuxtesting.org
To: andrianov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471354746-27110-1-git-send-email-andrianov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Andrianov <andrianov@ispras.ru>
Date: Tue, 16 Aug 2016 16:39:06 +0300

> smc_reset may be executed in parallel with timer function media_check.
> To avoid data race in smc_set_xcvr a spinlock was added.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Pavel Andrianov <andrianov@ispras.ru>

This is not sufficient.

You have to block basically the entire function, because both
smc_reset and media_check program the bank selection so could
corrupt eachother's register accesses.
