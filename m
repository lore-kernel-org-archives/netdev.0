From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH] IPV6 : add 64 bits components in struct in6_addr
 to speedup ipv6_addr_equal() & ipv6_addr_any()
Date: Mon, 30 Apr 2007 12:10:29 -0700 (PDT)
Message-ID: <20070430.121029.21927349.davem@davemloft.net>
References: <20070430162851.ca3c7869.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59366
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1946663AbXD3TKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 15:10:17 -0400
In-Reply-To: <20070430162851.ca3c7869.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 30 Apr 2007 16:28:51 +0200

> On 64bit arches, we can speedup some IPV6 addresses compares, using 64 bits fields in struct in6_addr.
> 
> I am not sure if this patch wont break some user ABI, maybe we should use some ifdef(KERNEL) ?
> 
> This patch saves some space, and also reduce number of conditional branches in ipv6_addr_equal()
> 
> # size vmlinux*
>    text    data     bss     dec     hex filename
> 6257978  692044  660472 7610494  74207e vmlinux
> 6259178  692044  660472 7611694  74252e vmlinux.before_patch
> 
> Note : Maybe ipv6_addr_cmp() could be defined on top of ipv6_addr_equal() ?
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Unfortunately, as mentioned elsewhere, we're only able to assume
32-bit alignment of ipv6 packet headers and that isn't likely to
change any time soon.

So, for example, you patch would fill my log file with unaligned trap
messages on my sparc64 workstation.
