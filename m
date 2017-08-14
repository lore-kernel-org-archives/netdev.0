From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Mon, 14 Aug 2017 09:33:07 -0700
Message-ID: <1502728387.4936.26.camel@edumazet-glaptop3.roam.corp.google.com>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
         <20170812142358.08291888@redhat.com>
         <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
         <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
         <20170814181957.5be27906@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35971 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752371AbdHNQdJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 12:33:09 -0400
Received: by mail-pg0-f67.google.com with SMTP id y129so11456207pgy.3
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 09:33:09 -0700 (PDT)
In-Reply-To: <20170814181957.5be27906@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-14 at 18:19 +0200, Jesper Dangaard Brouer wrote:

> The output (extracted below) didn't show who called 'do_raw_spin_lock',
> BUT it showed another interesting thing.  The kernel code
> __dev_queue_xmit() in might create route dst-cache problem for itself(?),
> as it will first call skb_dst_force() and then skb_dst_drop() when the
> packet is transmitted on a VLAN.
> 
>  static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
>  {
>  [...]
> 	/* If device/qdisc don't need skb->dst, release it right now while
> 	 * its hot in this cpu cache.
> 	 */
> 	if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
> 		skb_dst_drop(skb);
> 	else
> 		skb_dst_force(skb);

This is explained in this commit changelog.

https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=93f154b594fe47e4a7e5358b309add449a046cd3
