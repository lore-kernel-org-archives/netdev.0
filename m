From: Xiangning Yu <yuxiangning@gmail.com>
Subject: Question about veth_xmit()
Date: Mon, 23 Jan 2017 10:46:17 -0800
Message-ID: <CAOwmpL3vg56ZqHaYVBy+9dJJ1=GCbgy-m8NY0JrNCV-Z42R_eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36352 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750957AbdAWSqT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 13:46:19 -0500
Received: by mail-io0-f171.google.com with SMTP id j13so116955731iod.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 10:46:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev folks,

It looks like we call dev_forward_skb() in veth_xmit(), which calls
netif_rx() eventually.

While netif_rx() will enqueue the skb to the CPU RX backlog before the
actual processing takes place. So, this actually means a TX skb has to
wait some un-related RX skbs to finish. And this will happen twice for
a single ping, because the veth device always works as a pair?

IMHO this might lead to some latency issue under certain workload,
can we change the call to dev_forward_skb() to something like this?

        if (likely(__dev_forward_skb(rcv, skb) == NET_RX_SUCCESS)) {
                local_bh_disable();
                netif_receive_skb(skb);
                local_bh_enable();

Could you please shed some light on this change? And please feel free
to correct my if my understanding is wrong.

Thanks,

- Xiangning
