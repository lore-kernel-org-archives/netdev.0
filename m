From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: moxa: fix TX overrun memory leak
Date: Tue, 28 Mar 2017 18:02:16 -0700 (PDT)
Message-ID: <20170328.180216.784439214031823579.davem@davemloft.net>
References: <1490695958-23222-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: jonas.jensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39930 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932623AbdC2BCW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 21:02:22 -0400
In-Reply-To: <1490695958-23222-1-git-send-email-jonas.jensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Jensen <jonas.jensen@gmail.com>
Date: Tue, 28 Mar 2017 12:12:38 +0200

> moxart_mac_start_xmit() doesn't care where tx_tail is, tx_head can
> catch and pass tx_tail, which is bad because moxart_tx_finished()
> isn't guaranteed to catch up on freeing resources from tx_tail.
> 
> Add a check in moxart_mac_start_xmit() stopping the queue at the
> end of the circular buffer. Also add a check in moxart_tx_finished()
> waking the queue if the buffer has TX_WAKE_THRESHOLD or more
> free descriptors.
> 
> While we're at it, move spin_lock_irq() to happen before our
> descriptor pointer is assigned in moxart_mac_start_xmit().
> 
> Addresses https://bugzilla.kernel.org/show_bug.cgi?id=99451
> 
> Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>

Applied, thank you.
