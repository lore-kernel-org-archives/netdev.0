From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] sky2: Fix crash inside sky2_rx_clean
Date: Wed, 26 Nov 2014 10:57:10 -0800
Message-ID: <20141126105710.0622a7c0@urahara>
References: <5475E012.3060607@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mirko Lindner <mlindner@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:45847 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbaKZS5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 13:57:19 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so3396714pab.12
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 10:57:19 -0800 (PST)
In-Reply-To: <5475E012.3060607@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Nov 2014 15:13:38 +0100
Mirko Lindner <mlindner@marvell.com> wrote:

> If sky2->tx_le = pci_alloc_consistent() or sky2->tx_ring = kcalloc() in
> sky2_alloc_buffers() fails, sky2->rx_ring = kcalloc() will never be called.
> In this error case handling, sky2_rx_clean() is called from within
> sky2_free_buffers().
> 
> In sky2_rx_clean() we find the following:
> 
> ...
>    memset(sky2->rx_le, 0, RX_LE_BYTES);
> ...
> 
> This results in a memset using a NULL pointer and will crash the system.
> 
> Signed-off-by: Mirko Lindner <mlindner@marvell.com>

This matches my earlier patch, but this one is just as good

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
