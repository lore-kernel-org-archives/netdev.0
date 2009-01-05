From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] qlge: bugfix: Fix shadow register endian issue.
Date: Sun, 04 Jan 2009 17:09:38 -0800 (PST)
Message-ID: <20090104.170938.210170335.davem@davemloft.net>
References: <20081230211122.GD16018@susedev.qlogic.org>
	<1230671545-19084-3-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com,
	bhutchings@solarflare.com, hch@infradead.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40526
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751305AbZAEBJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 20:09:34 -0500
In-Reply-To: <1230671545-19084-3-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Tue, 30 Dec 2008 13:12:23 -0800

> Shadow registers are consistent memory locations to which the chip
> echos ring indexes in little endian format.  These values need to
> be endian swapped before referencing.
> 
> Note:
> The register pointer declaration uses the volatile modifier which
> causes warnings in checkpatch.
> Per Documentation/volatile-considered-harmful.txt:
>   - Pointers to data structures in coherent memory which might be modified
>     by I/O devices can, sometimes, legitimately be volatile.  A ring buffer
>     used by a network adapter, where that adapter changes pointers to
>     indicate which descriptors have been processed, is an example of this
>     type of situation.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied, but still kill the volatile and use proper memory
barriers around accesses to this value instead.

Many other drivers handle exactly this situation without
having to resort to volatile.
