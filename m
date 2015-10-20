From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: sh_eth.c::sh_eth_rx(): mdp->rx_skbuff[entry] can be NULL
Date: Tue, 20 Oct 2015 23:48:01 +0300
Message-ID: <5626A881.2080701@cogentembedded.com>
References: <87oafusy11.wl@dns1.atmark-techno.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Yasushi SHOJI <yashi@atmark-techno.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:36650 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274AbbJTUsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 16:48:06 -0400
Received: by lffz202 with SMTP id z202so11866617lff.3
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 13:48:03 -0700 (PDT)
In-Reply-To: <87oafusy11.wl@dns1.atmark-techno.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/19/2015 06:01 PM, Yasushi SHOJI wrote:

> In a low memory situation with netdev_alloc_skb() failure,
> mdp->rx_skbuff[entry] can be left NULL, however, sh_eth_rx() seems to
> access it without checking NULL or not in the following code:
>
> 			skb = mdp->rx_skbuff[entry];
> 			mdp->rx_skbuff[entry] = NULL;
> 			if (mdp->cd->rpadir)
> 				skb_reserve(skb, NET_IP_ALIGN);
> 			dma_unmap_single(&ndev->dev, rxdesc->addr,
> 					 ALIGN(mdp->rx_buf_sz, 16),
> 					 DMA_FROM_DEVICE);
>
> I've put BUG_ON() to test skb and got the following backtrace.  I can
> also enable slub poisoning to see some bad access.
>
> I'm not that familiar with this code base so I'm note including any
> patch yet.  I appreciate if someone with insight in this code give a
> quick look and tell me that it's a real one or not.  if this is a real
> case, I can take a deep look.

    If you got the oops, it's real. Thanks for the reporting. I guess I should 
check the new ravb driver as well...
    Do you want to try fixing the bug yourself?

> BTW, the backtrace is from old 3.4.74+ kernel but the current tip is
> very close.

     Yeah, this part didn't change in a long time...

> Thanks,

MBR, Sergei
