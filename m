From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smc91c92_cs : add a spinlock to avoid race condition
Date: Thu, 18 Aug 2016 23:00:55 -0700 (PDT)
Message-ID: <20160818.230055.1587442048794416891.davem@davemloft.net>
References: <1471354746-27110-1-git-send-email-andrianov@ispras.ru>
        <20160818.210734.1003452853595787957.davem@davemloft.net>
        <57B68DFC.4070204@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrianov@ispras.ru, mugunthanvnm@ti.com, a@unstable.cc,
        felipe.balbi@linux.intel.com, fw@strlen.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: vaishali.thakkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57B68DFC.4070204@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Date: Fri, 19 Aug 2016 10:11:32 +0530

> 
> 
> On Friday 19 August 2016 09:37 AM, David Miller wrote:
>> From: Pavel Andrianov <andrianov@ispras.ru>
>> Date: Tue, 16 Aug 2016 16:39:06 +0300
>> 
>>> smc_reset may be executed in parallel with timer function media_check.
>>> To avoid data race in smc_set_xcvr a spinlock was added.
>>>
>>> Found by Linux Driver Verification project (linuxtesting.org).
>>>
>>> Signed-off-by: Pavel Andrianov <andrianov@ispras.ru>
>> 
>> This is not sufficient.
>> 
>> You have to block basically the entire function, because both
>> smc_reset and media_check program the bank selection so could
>> corrupt eachother's register accesses.
> 
> Hmm, but then there is a use of udelay as well. Would it be still
> fine to acquire a spinlock on whole function?

I don't know, but what I'm telling you is that you have to execute
register programming these two functions do atomically so that the
bank selection doesn't check get changed midstream.
