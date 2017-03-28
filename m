From: Salam Noureddine <noureddine@arista.com>
Subject: Null pointer dereference in tg3_poll_work running linux-3.4
Date: Tue, 28 Mar 2017 11:32:40 -0700
Message-ID: <CAO7SqHCqADHoZMy7+quaF83-Ln24A=xx10D1Tv9=SX5DFsncpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mchan@broadcom.com, prashant@broadcom.com, siva.kallam@broadcom.com
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f53.google.com ([209.85.213.53]:36228 "EHLO
        mail-vk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755487AbdC1SdP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 14:33:15 -0400
Received: by mail-vk0-f53.google.com with SMTP id s68so98784129vke.3
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 11:33:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We've seen a very rare kernel panic in tg3_poll_work on hardware
running linux-3.4.
I haven't seen any upstream patches that seem to fix this issue in the
tg3 driver.
The disassembly shows that the panic is happening in tg3_rx which is
inlined into
tg3_poll_work. In the code below, the "data" pointer seem to be Null,

                        tg3_recycle_rx(tnapi, tpr, opaque_key,
                                       desc_idx, *post_ptr);

                        skb = netdev_alloc_skb(tp->dev,
                                               len + TG3_RAW_IP_ALIGN);

                        if (skb == NULL)
                                goto drop_it_no_recycle;

                        skb_reserve(skb, TG3_RAW_IP_ALIGN);
                        pci_dma_sync_single_for_cpu(tp->pdev,
dma_addr, len, PCI_DMA_FROMDEVICE);
                        memcpy(skb->data,
                               data + TG3_RX_OFFSET(tp),
                               len);

                        pci_dma_sync_single_for_device(tp->pdev, dma_addr, len,
PCI_DMA_FROMDEVICE);

I am wondering if anyone has seen this before or if it was fixed and I
missed the patch for it. If not,
any ideas on how we could end up with data being null? I don't have a
reproduction scenario for
this one.

Thanks,

Salam
