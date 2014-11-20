From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Thu, 20 Nov 2014 12:41:44 -0800
Message-ID: <1416516104.8629.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com>
	 <1416375565.14060.43.camel@edumazet-glaptop2.roam.corp.google.com>
	 <546C4022.5010509@oracle.com>
	 <CAHA+R7OyA_V149bpE8qUgG9epU-5UG8cf=zOgh5ZXVB3ZFZHUw@mail.gmail.com>
	 <1416465685.8629.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7PKRbBNwfUWRAsVHQreKsGXBc8CHorZRuyCfvwL4O=y+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wengang <wen.gang.wang@oracle.com>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:49349 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756880AbaKTUlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 15:41:47 -0500
Received: by mail-ig0-f173.google.com with SMTP id r2so5462028igi.12
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 12:41:46 -0800 (PST)
In-Reply-To: <CAHA+R7PKRbBNwfUWRAsVHQreKsGXBc8CHorZRuyCfvwL4O=y+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-20 at 09:34 -0800, Cong Wang wrote:

> I didn't look into ipoib_header_ops, thought it might have some dependency
> on symbols.

I did look before answering and suggesting this, you really should do
the same instead of giving advices of over engineering the stack.

Best is the enemy of the good.

Its hard to find some networking function trivial than this one.


static int ipoib_hard_header(struct sk_buff *skb,
                             struct net_device *dev,
                             unsigned short type,
                             const void *daddr, const void *saddr, unsigned len)
{
        struct ipoib_header *header;
        struct ipoib_cb *cb = ipoib_skb_cb(skb);

        header = (struct ipoib_header *) skb_push(skb, sizeof *header);

        header->proto = htons(type);
        header->reserved = 0;

        /*
         * we don't rely on dst_entry structure,  always stuff the
         * destination address into skb->cb so we can figure out where
         * to send the packet later.
         */
        memcpy(cb->hwaddr, daddr, INFINIBAND_ALEN);

        return sizeof *header;
}
