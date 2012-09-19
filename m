From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] mlx4: use dev_kfree_skb() instead of
 dev_kfree_skb_any()
Date: Wed, 19 Sep 2012 14:12:57 +0200
Message-ID: <1348056777.26523.750.camel@edumazet-glaptop>
References: <1347866974.26523.53.camel@edumazet-glaptop>
	 <953B660C027164448AE903364AC447D28721B46E@MTLDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, Ying Cai <ycai@google.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:65396 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756280Ab2ISMNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 08:13:04 -0400
Received: by bkwj10 with SMTP id j10so472923bkw.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 05:13:02 -0700 (PDT)
In-Reply-To: <953B660C027164448AE903364AC447D28721B46E@MTLDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 07:58 +0000, Yevgeny Petrilin wrote:
> > 
> > Since commit e22979d96a5 (mlx4_en: Moving to Interrupts for TX
> > completions), we no longer can free TX skb from hard IRQ, but only from
> > normal softirq or process context.
> > 
> > Therefore, we can directly call dev_kfree_skb() from
> > mlx4_en_free_tx_desc() like other conventional NAPI drivers.
> > 
> 
> Hi Eric,
> At the moment the TX completion processing is done from IRQ context.
> So I think we need to change the driver to work with NAPI for TX completions
> before making this change.
> 
> I'll send the patch in a few days.

Oops you're right, it seems I misread e22979d96 commit.

irq term is a bit generic, you might add soft/hard qualifiers to
distinguish the variant.

Thanks
