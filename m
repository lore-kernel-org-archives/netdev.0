From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 14/15] netpoll: re-enable irq in poll_napi()
Date: Sat, 25 Aug 2012 14:28:40 +0800
Message-ID: <1345876120.14276.19.camel@cr0>
References: <1344597891-32242-1-git-send-email-amwang@redhat.com>
	 <1344597891-32242-15-git-send-email-amwang@redhat.com>
	 <20120824124334.10313575.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2900 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732Ab2HYG2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2012 02:28:48 -0400
In-Reply-To: <20120824124334.10313575.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 12:43 -0700, Andrew Morton wrote:
> 
> This commit (6bdb7fe3104 in mainline) makes my netconsole-using x86_64
> box lock up during boot.  Dunno why, but I do have a cellphone:
> http://ozlabs.org/~akpm/stuff/IMG_20120824_122054.jpg
> 

Thanks for the report!

Sylvain reported a CPU stall problem which is probably caused by this
commit too.

This commit is to fix another issue, that is, we call be_process_mcc()
which calls spin_lock_bh() with IRQ disabled, this leads to a warning
in:

static inline void _local_bh_enable_ip(unsigned long ip)
{
        WARN_ON_ONCE(in_irq() || irqs_disabled());
	...
}

I think I should just fix be_process_mcc(), instead of re-enabling IRO
for all ->poll callbacks.

I will send a patch to David soon.
