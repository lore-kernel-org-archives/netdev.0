From: Cong Wang <cwang@twopensource.com>
Subject: Re: Sending undersized ARP packets with VXLAN L3 interface
Date: Wed, 27 Aug 2014 10:28:56 -0700
Message-ID: <CAHA+R7Ok6K_9U6RCZkSLCuVXtFG4Zs60FQKFZMu-v2yK581hog@mail.gmail.com>
References: <CAMYYbY79hOVA5b22-gmLJTNQwprdfwa_QxKqveuwNhJMcXv9tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Martin Rusko <martin.rusko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:34110 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933836AbaH0R25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 13:28:57 -0400
Received: by mail-la0-f42.google.com with SMTP id pi18so301972lab.1
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 10:28:56 -0700 (PDT)
In-Reply-To: <CAMYYbY79hOVA5b22-gmLJTNQwprdfwa_QxKqveuwNhJMcXv9tA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2014 at 10:06 AM, Martin Rusko <martin.rusko@gmail.com> wrote:
>
> I'm wondering, where is the proper place to fix this. Should
> arp_create() function allocate skb big enough to produce ethernet
> frame with at least minimum size? Or is it somewhere in NIC drivers
> where small packets are padded with zeros?

Drivers do that, for example e1000:

        /* On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
         * packets may get corrupted during padding by HW.
         * To WA this issue, pad all small packets manually.
         */
        if (skb->len < ETH_ZLEN) {
                if (skb_pad(skb, ETH_ZLEN - skb->len))
                        return NETDEV_TX_OK;
                skb->len = ETH_ZLEN;
                skb_set_tail_pointer(skb, ETH_ZLEN);
        }
