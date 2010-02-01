From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v2] net: export TCP send buffer size via netlink
Date: Mon, 01 Feb 2010 02:00:55 -0800 (PST)
Message-ID: <20100201.020055.57470143.davem@davemloft.net>
References: <20100201092153.4194.91507.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100201092153.4194.91507.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amerigo Wang <amwang@redhat.com>
Date: Mon, 1 Feb 2010 04:18:28 -0500

> V1 -> V2:
> Keep ABI compatiblity of struct tcp_info.
> 
> Currently, we can only get TCP send buffer size by
> getsockopt (SO_SNDBUF or TCP_INFO), this is not enough
> for the tools like netstat or ss to read.
> 
> Show TCP send buffer size via netlink NETLINK_INET_DIAG.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>

If the user has a "struct tcp_info info" on it's stack,
and it's compiled against the header file before your
changes, guess what the kernel is going to do?

It's going to write past the end of the user's variable
into random stack locations.

You can't change the layout, at all.
