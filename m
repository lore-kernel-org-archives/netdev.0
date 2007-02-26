From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 4/5] r8169: more alignment for the 0x8168
Date: Mon, 26 Feb 2007 14:25:28 -0800
Message-ID: <20070226142528.6b68a0cb@freekitty>
References: <20061203235257.GA3625@electric-eye.fr.zoreil.com>
	<20061204000327.GE3625@electric-eye.fr.zoreil.com>
	<45D13578.8040405@snapgear.com>
	<20070213081439.GA21261@electric-eye.fr.zoreil.com>
	<Pine.LNX.4.64.0702131730570.14346@cnc.isely.net>
	<20070223231355.GA10930@electric-eye.fr.zoreil.com>
	<45E28F63.8000208@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Mike Isely <isely@pobox.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36254 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161296AbXBZW0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 17:26:05 -0500
In-Reply-To: <45E28F63.8000208@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Feb 2007 17:42:27 +1000
Philip Craig <philipc@snapgear.com> wrote:

> Francois Romieu wrote:
> > The experimental r8169 patch of the day against 2.6.21-rc1 is available at:
> > http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc1/
> 
> Is 0006-r8169-confusion-between-hardware-and-IP-header-alignment.txt
> the only relevant patch?
> 
> This only partially helps.  Many of the packets are greater than 200
> bytes so copybreak doesn't apply to them.
> 
> Can we assume anything about the alignment of skb->data?  I think it
> should be 4 byte aligned, otherwise the whole NET_IP_ALIGN thing
> won't work.  All the drivers I looked at just reserve NET_IP_ALIGN
> without checking the alignment first.
>

This is where the alignment comes from in slab.c

#ifndef ARCH_KMALLOC_MINALIGN
/*
 * Enforce a minimum alignment for the kmalloc caches.
 * Usually, the kmalloc caches are cache_line_size() aligned, except when
 * DEBUG and FORCED_DEBUG are enabled, then they are BYTES_PER_WORD aligned.
 * Some archs want to perform DMA into kmalloc caches and need a guaranteed
 * alignment larger than BYTES_PER_WORD. ARCH_KMALLOC_MINALIGN allows that.
 * Note that this flag disables some debug features.
 */
#define ARCH_KMALLOC_MINALIGN 0
#endif

Since BYTES_PER_WORD is sizeof(void *) you are safe since Linux doesn't
run on 16 bit platforms.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
