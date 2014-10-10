From: Tom Herbert <therbert@google.com>
Subject: Re: eth_get_headlen() and unaligned accesses...
Date: Fri, 10 Oct 2014 11:41:46 -0700
Message-ID: <CA+mtBx-8S6eWuKin0eEaeMiDr-0f+ivy3q+s150i2n3X8T0zyg@mail.gmail.com>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36355 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbaJJSlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 14:41:47 -0400
Received: by mail-ig0-f181.google.com with SMTP id r10so3807534igi.14
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 11:41:46 -0700 (PDT)
In-Reply-To: <20141009.201248.1210454965155680255.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 9, 2014 at 5:12 PM, David Miller <davem@davemloft.net> wrote:
>
> So, we have a bit of a problem, this is on sparc64:
>
> [423475.740836] Kernel unaligned access at TPC[81d330] __skb_flow_get_ports+0x70/0xe0
> [423475.755756] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.17.0+ #2
> [423475.767854] Call Trace:
> [423475.772877]  [0000000000433288] kernel_unaligned_trap+0x368/0x5c0
> [423475.785203]  [000000000042a824] sun4v_do_mna+0x84/0xa0
> [423475.795624]  [0000000000406cd0] sun4v_mna+0x5c/0x68
> [423475.805521]  [000000000081d330] __skb_flow_get_ports+0x70/0xe0
> [423475.817323]  [000000000081d6ac] __skb_flow_dissect+0x1ac/0x460
> [423475.829128]  [0000000000843c98] eth_get_headlen+0x38/0xa0
> [423475.840083]  [0000000010064d54] igb_poll+0x8d4/0xf60 [igb]
> [423475.851184]  [00000000008243c8] net_rx_action+0xa8/0x1c0
>
> The chip DMA's to the beginning of a frag page and (unless timestamps
> are enabled) that's where the ethernet header begins.
>
> So any larger than 16-bit access to the IP and later headers will be
> unaligned.
>
Will this also be a problem for GRE packet carrying Ethernet packet?

> We have various ways we can deal with this based upon the capabilities
> of the chips involved.  Can we configure the IGB to put 2 "don't care"
> bytes at the beginning of the packet?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
