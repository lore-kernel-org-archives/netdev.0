From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] TCP connection repair (v4)
Date: Sat, 21 Apr 2012 15:53:54 -0400 (EDT)
Message-ID: <20120421.155354.769351486098851306.davem@davemloft.net>
References: <4F901572.4040009@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab2DUTx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 15:53:57 -0400
In-Reply-To: <4F901572.4040009@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 19 Apr 2012 17:38:58 +0400

> Attempt #4 with an API for TCP connection recreation (previous one is
> at http://lists.openwall.net/netdev/2012/03/28/84) re-based on the
> today's net-next tree.
> 
> Changes since v3:
> 
> * Added repair for TCP options negotiated during 3WHS process, pointed
>   out by Li Yu. The explanation of how this happens is in patch #6.
> 
> * Named constant for sk_reuse values as proposed by Ben Hutching.
> 
> * Off-by-one in repair-queue sockoption caught by Ben.

All applied to net-next, nice work.

Please make the following fix for me.  The option recovery code will
result in unaligned accesses, for example you'll do a byte aligned
get_user() for the u16 MSS object in many cases, and this will trap
and cpus such as sparc.

Either add a padding facility or pass more structured data into the
socket option.

Thanks.
