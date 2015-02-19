From: David Miller <davem@davemloft.net>
Subject: Re: Possible Bug in gnet_start_copy_compat for the file,gen_stats.c
Date: Thu, 19 Feb 2015 15:34:56 -0500 (EST)
Message-ID: <20150219.153456.2128213121930417861.davem@davemloft.net>
References: <54DD626C.80505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, standby24x7@gmail.com,
	xiyou.wangcong@gmail.com, rdunlap@infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xerofoify@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54DD626C.80505@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: nick <xerofoify@gmail.com>
Date: Thu, 12 Feb 2015 21:33:16 -0500

> I am wondering after running sparse on the latest mainline tree why
> we are not unlocking the spinlock_bh,lock when calling the function,
> gnet_stats_start_copy_compat at the end of this function's
> body. Unless someone can explain to me why there is a very good
> reason for not unlocking the spinlock_bh,lock at the end of this
> function I will send in a patch fixing this. I am assuming this is a
> bug due to us infinitely looping in the spinlock_bh and deadlocking
> unless we exit this lock external to the call to the
> function,gnet_start_copy_compat.

This function is used to start a dump, and the caller needs the lock
to be held during the dump operation.

The lock is released by the caller by invoking gnet_stats_finish_copy().
