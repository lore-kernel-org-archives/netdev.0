From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sky2: Do not deadlock on sky2_hw_down
Date: Thu, 25 May 2017 13:42:05 -0400 (EDT)
Message-ID: <20170525.134205.884395652948196578.davem@davemloft.net>
References: <20170524224353.124692-1-jemele@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jemele@google.com, mlindner@marvell.com,
        stephen@networkplumber.org, linux-kernel@vger.kernel.org
To: jemele@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170524224353.124692-1-jemele@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joshua Emele <jemele@gmail.com>
Date: Wed, 24 May 2017 15:43:18 -0700

> From: Joshua Emele <jemele@google.com>
> 
> The sky2_hw_down uses sky2_tx_complete to free pending frames stuck in
> the HW queue. Because sky2_hw_down can be called from a process context,
> the call to u64_stats_update_begin can result in deadlock.
> 
> Because the statistics do not require update as part of the sky2_hw_down
> sequence, prevent the update to avoid the deadlock.

I disagree.  Taking the interface down should cause events in the
statistics to be lost.

You're going to have to find a way to fix this without eliding
the stats increments.

Thanks.
