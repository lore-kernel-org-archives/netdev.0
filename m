From: Ying Cai <ycai@google.com>
Subject: Re: [PATCH net-next] mlx4: use dev_kfree_skb() instead of dev_kfree_skb_any()
Date: Wed, 19 Sep 2012 14:21:12 -0700
Message-ID: <CAL1qit_pkQ7YBzcAPMSWF4zeFS6yFj18P1yJMvj_Z-7SRMxeRg@mail.gmail.com>
References: <1347866974.26523.53.camel@edumazet-glaptop>
	<953B660C027164448AE903364AC447D28721B46E@MTLDAG01.mtl.com>
	<1348056777.26523.750.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:50971 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787Ab2ISVVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 17:21:13 -0400
Received: by ieak13 with SMTP id k13so2284748iea.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 14:21:12 -0700 (PDT)
In-Reply-To: <1348056777.26523.750.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yevgeny,

It seems all the TxQs are sharing the same interrupt for Tx
completions. Will it be better to have separate interrupt per
num_tx_rings_p_up (8) queues? E.g. for a 16 core system, with 16 * 8
Tx queues, to have 16 interrupts for Tx completions of those 128 Tx
queues?

Also I'm looking at mlx4_en_select_queue(), it is using
__skb_tx_hash(). Use something to achieve XPS may bring better
performances.

Thanks.

On Wed, Sep 19, 2012 at 5:12 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> On Wed, 2012-09-19 at 07:58 +0000, Yevgeny Petrilin wrote:
> > >
> > > Since commit e22979d96a5 (mlx4_en: Moving to Interrupts for TX
> > > completions), we no longer can free TX skb from hard IRQ, but only
> > > from
> > > normal softirq or process context.
> > >
> > > Therefore, we can directly call dev_kfree_skb() from
> > > mlx4_en_free_tx_desc() like other conventional NAPI drivers.
> > >
> >
> > Hi Eric,
> > At the moment the TX completion processing is done from IRQ context.
> > So I think we need to change the driver to work with NAPI for TX
> > completions
> > before making this change.
> >
> > I'll send the patch in a few days.
>
> Oops you're right, it seems I misread e22979d96 commit.
>
> irq term is a bit generic, you might add soft/hard qualifiers to
> distinguish the variant.
>
> Thanks
>
>
