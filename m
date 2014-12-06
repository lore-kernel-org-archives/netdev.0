From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: correct the endianness of
 doorbell_qpn on big endian platform
Date: Fri, 05 Dec 2014 21:31:12 -0800 (PST)
Message-ID: <20141205.213112.1199355931404701216.davem@davemloft.net>
References: <1417315431-16761-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gideonn@mellanox.com, edumazet@google.com,
	amirv@mellanox.com
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746AbaLFF0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 00:26:43 -0500
In-Reply-To: <1417315431-16761-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Sun, 30 Nov 2014 10:43:51 +0800

> In commit 6a4e812 (net/mlx4_en: Avoid calling bswap in tx fast path), we store
> doorbell_qpn in big endian to avoid bswap(). Then we try to write it directly
> by iowrite32() instead of iowrite32be().
> 
> This works fine on little endian platform, while has some problem on big
> endian platform. Here is the definition in general:
> 
> 	#define iowrite32(v, addr)	writel((v), (addr))
> 	#define writel(b,addr)		__raw_writel(__cpu_to_le32(b),addr)
> 
> On little endian platform, the value is not swapped before write. While on big
> endian platform, the value is swapped. This is not expected to happen.
> 
> This patch does the swap on big endian platform before it is written.
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>

Guys, let's figure out what we are doing with this patch.
