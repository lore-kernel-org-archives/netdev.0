From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Subject: Re: [PATCH] smc91c92_cs : add a spinlock to avoid race condition
Date: Fri, 19 Aug 2016 10:11:32 +0530
Message-ID: <57B68DFC.4070204@oracle.com>
References: <1471354746-27110-1-git-send-email-andrianov@ispras.ru>
 <20160818.210734.1003452853595787957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, a@unstable.cc, felipe.balbi@linux.intel.com,
        fw@strlen.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org
To: David Miller <davem@davemloft.net>, andrianov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160818.210734.1003452853595787957.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Friday 19 August 2016 09:37 AM, David Miller wrote:
> From: Pavel Andrianov <andrianov@ispras.ru>
> Date: Tue, 16 Aug 2016 16:39:06 +0300
> 
>> smc_reset may be executed in parallel with timer function media_check.
>> To avoid data race in smc_set_xcvr a spinlock was added.
>>
>> Found by Linux Driver Verification project (linuxtesting.org).
>>
>> Signed-off-by: Pavel Andrianov <andrianov@ispras.ru>
> 
> This is not sufficient.
> 
> You have to block basically the entire function, because both
> smc_reset and media_check program the bank selection so could
> corrupt eachother's register accesses.

Hmm, but then there is a use of udelay as well. Would it be still
fine to acquire a spinlock on whole function?

> 

-- 
Vaishali
