From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] gianfar: fix size of scatter-gathered frames
Date: Tue, 23 Aug 2016 16:49:13 -0700 (PDT)
Message-ID: <20160823.164913.1405890361099687642.davem@davemloft.net>
References: <1471598156-16875-1-git-send-email-zefir.kurtisi@neratec.com>
        <1471874292-15425-1-git-send-email-zefir.kurtisi@neratec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com,
        andrew@lunn.ch
To: zefir.kurtisi@neratec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55823 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753311AbcHWXtO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 19:49:14 -0400
In-Reply-To: <1471874292-15425-1-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Date: Mon, 22 Aug 2016 15:58:12 +0200

> The current scatter-gather logic in gianfar is flawed, since
> it does not consider the eTSEC's RxBD 'Data Length' field is
> context depening: for the last fragment it contains the full
> frame size, while fragments contain the fragment size, which
> equals the value written to register MRBLR.
> 
> This causes data corruption as soon as the hardware starts
> to fragment receiving frames. As a result, the size of
> fragmented frames is increased by
> (nr_frags - 1) * MRBLR
> 
> We first noticed this issue working with DSA, where an ICMP
> request sized 1472 bytes causes the scatter-gather logic to
> kick in. The full Ethernet frame (1518) gets increased by
> DSA (4), GMAC_FCB_LEN (8), and FSL_GIANFAR_DEV_HAS_TIMER
> (priv->padding=8) to a total of 1538 octets, which is
> fragmented by the hardware and reconstructed by the driver
> to a 3074 octet frame.
> 
> This patch fixes the problem by adjusting the size of
> the last fragment.
> 
> It was tested by setting MRBLR to different multiples of
> 64, proving correct scatter-gather operation on frames
> with up to 9000 octets in size.
> 
> Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>

Applied.
