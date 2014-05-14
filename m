From: David Miller <davem@davemloft.net>
Subject: Re: icmp: account for ICMP out errors because of socket limit
Date: Wed, 14 May 2014 14:07:53 -0400 (EDT)
Message-ID: <20140514.140753.222006976691406699.davem@davemloft.net>
References: <53703DC0.2070204@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, Yue.Tao@windriver.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: zyjzyj2000@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53703DC0.2070204@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: zhuyj <zyjzyj2000@gmail.com>
Date: Mon, 12 May 2014 11:19:28 +0800

> Hi, Eric && David
> 
>  ____           ______________
> |    |         |              |
> | PC |<------->| MIPS 32 core |
> |____|         |______________|
> 
> When ping from a PC to a board (MIPS 32 core), because of socket
> limit,
> ping echo will fail. But ICMP_MIB_OUTERRORS counter is not
> incremented.
> In this case, "netstat -s" can not report these errors.
> 
> This patch will fix this problem. Now it is in the attachment. Please
> check it.

The only time icmp_xmit_lock() can fail is if we try to generate an ICMP
response to a failure to send another ICMP packet.

It is an entirely different situation from Eric's other patch which
you've mentioned in this thread, and I do not think this case warrants
a statistic bump at all.
