From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make neigh_priv_len in struct net_device 16bit
 instead of 8bit
Date: Thu, 12 Dec 2013 15:35:26 -0500 (EST)
Message-ID: <20131212.153526.1142755230387840010.davem@davemloft.net>
References: <1386839759-24042-1-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rostedt@goodmis.org, tglx@linutronix.de
To: bigeasy@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674Ab3LLUf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 15:35:28 -0500
In-Reply-To: <1386839759-24042-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 12 Dec 2013 10:15:59 +0100

> neigh_priv_len is defined as u8. With all debug enabled struct
> ipoib_neigh has 200 bytes. The largest part is sk_buff_head with 96
> bytes and here the spinlock with 72 bytes.
> The size value still fits in this u8 leaving some room for more.
> 
> On -RT struct ipoib_neigh put on weight and has 392 bytes. The main
> reason is sk_buff_head with 288 and the fatty here is spinlock with 192
> bytes. This does no longer fit into into neigh_priv_len and gcc
> complains.
> 
> This patch changes neigh_priv_len from being 8bit to 16bit. Since the
> following element (dev_id) is 16bit followed by a spinlock which is
> aligned, the struct remains with a total size of 3200 (allmodconfig) /
> 2048 (with as much debug off as possible) bytes on x86-64.
> On x86-32 the struct is 1856 (allmodconfig) / 1216 (with as much debug
> off as possible) bytes long. The numbers were gained with and without
> the patch to prove that this change does not increase the size of the
> struct.
> 
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

This is fine, applied, thanks.
