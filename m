From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: fix /proc/net/ip_mr_cache display - V2
Date: Wed, 03 Dec 2008 22:21:58 -0800 (PST)
Message-ID: <20081203.222158.256869794.davem@davemloft.net>
References: <20081202.150330.157587697.davem@davemloft.net>
	<49368E23.6070406@bull.net>
	<20081203143540.414771888@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44389
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752260AbYLDGV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 01:21:58 -0500
In-Reply-To: <20081203143540.414771888@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Wed, 03 Dec 2008 15:35:41 +0100

> /proc/net/ip_mr_cache and /proc/net/ip6_mr_cache displays garbage when
> showing unresolved mfc_cache entries.
> 
> [root@qemu tests]# cat /proc/net/ip_mr_cache
> Group    Origin   Iif     Pkts    Bytes    Wrong Oifs
> 014C00EF 010014AC 1         10    10050        0  2:1    3:1
> 024C00EF 010014AC 65535      514        2 -559067475
> 
> The first line is correct. It is a resolved cache entry, 10 packets used it...
> The second line represents an unresolved entry, and the columns Pkts(4th),
> Bytes(5th) and Wrong(6th) just show garbage.
> 
> In struct mfc_cache, there's an union to store data for resolved and
> unresolved cases. And what ipmr_mfc_seq_show() is printing in these 
> columns for the unresolved entries is some bytes from mfc_cache.mfc_un.res.
> Bad.
> (eg. In our case -559067475 is in fact 0xdead4ead which is the spinlock
> magic from mfc_cache.mfc_un.unres.unresolved.lock.magic).
> 
> This patch replaces the garbage data written in these columns for the
> unresolved entries by '0' (zeros) which is more correct.
> This change doesn't break the ABI.
> 
> Also, mfc->mfc_un.res.pkt, mfc->mfc_un.res.bytes, mfc->mfc_un.res.wrong_if
> are unsigned long.
> 
> It applies on top of net-next-2.6.
> 
> The patch for net-2.6 is slightly different because of the NIP6_FMT to
> %pI6 conversion that was made in the seq_printf.
> 
> Changelog:
> ==========
> V2:
> * Instead of breaking the ABI by suppressing the columns that have no
>   meaning for unresolved entries, fill them with 0 values.
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied to net-next-2.6
