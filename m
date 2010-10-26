From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for October 25 (netfilter/xt_socket)
Date: Mon, 25 Oct 2010 22:02:54 -0700 (PDT)
Message-ID: <20101025.220254.183041135.davem@davemloft.net>
References: <20101025145834.9b68e026.sfr@canb.auug.org.au>
	<20101025165407.74b0c0a0.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101025165407.74b0c0a0.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 25 Oct 2010 16:54:07 -0700

> xt_socket.c:(.text+0x39ff8): undefined reference to `ipv6_find_hdr'
> xt_socket.c:(.init.text+0x1703): undefined reference to `nf_defrag_ipv6_enable'

This ought to be fixed in net-2.6 already, by:

commit f6318e558806c925029dc101f14874be9f9fa78f
Author: KOVACS Krisztian <hidden@balabit.hu>
Date:   Sun Oct 24 23:38:32 2010 +0000

    netfilter: fix module dependency issues with IPv6 defragmentation, ip6tables and xt_TPROXY
    
    One of the previous tproxy related patches split IPv6 defragmentation and
    connection tracking, but did not correctly add Kconfig stanzas to handle the
    new dependencies correctly. This patch fixes that by making the config options
    mirror the setup we have for IPv4: a distinct config option for defragmentation
    that is automatically selected by both connection tracking and
    xt_TPROXY/xt_socket.
    
    The patch also changes the #ifdefs enclosing IPv6 specific code in xt_socket
    and xt_TPROXY: we only compile these in case we have ip6tables support enabled.
    
    Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
    Signed-off-by: David S. Miller <davem@davemloft.net>
