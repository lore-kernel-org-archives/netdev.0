From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_eth alignment fix for sh7724 using NET_IP_ALIGN
Date: Mon, 14 Dec 2009 21:57:53 -0800 (PST)
Message-ID: <20091214.215753.147971281.davem@davemloft.net>
References: <20091214103443.13082.84079.sendpatchset@rxone.opensource.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: magnus.damm@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20091214103443.13082.84079.sendpatchset@rxone.opensource.se>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Magnus Damm <magnus.damm@gmail.com>
Date: Mon, 14 Dec 2009 19:34:43 +0900

> From: Magnus Damm <damm@opensource.se>
> 
> Fix sh_eth for sh7724 by adding NET_IP_ALIGN support.
> Without this patch the receive data is misaligned.
> 
> Signed-off-by: Magnus Damm <damm@opensource.se>

How does this interact with sh_eth_set_receive_align() and
why isn't all of the skb_reserve() logic confined to one
place?

The sh7763 sh_eth_my_cpu_data sets rpadir unconditionally,
yet your NET_IP_ALIGN behavior is controlled by the new
setting of .rpadir for sh7724, is this ok or is it going
to break sh7763 or cause it to misbehave?

Could you possibly generalize this so that you don't
need the ifdefs and it doesn't matter what the NET_IP_ALIGN
value actually is?  That is making this code more confusing
than it needs to be.

Thanks.

