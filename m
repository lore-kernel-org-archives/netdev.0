From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net: fs_enet: Fix NETIF_F_SG feature for
 Freescale MPC5121
Date: Tue, 23 Jun 2015 06:39:26 -0700 (PDT)
Message-ID: <20150623.063926.723221732046739833.davem@davemloft.net>
References: <1434839566-31704-1-git-send-email-alex.popov@linux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	christophe.leroy@c-s.fr, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alex.popov@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33464 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229AbbFWN1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:27:38 -0400
In-Reply-To: <1434839566-31704-1-git-send-email-alex.popov@linux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Popov <alex.popov@linux.com>
Date: Sun, 21 Jun 2015 01:32:46 +0300

> Commit 4fc9b87bae25 ("net: fs_enet: Implement NETIF_F_SG feature")
> brings a trouble to Freescale MPC512x: a kernel oops happens
> during sending non-linear sk_buff with .data not aligned by 4.
> 
> Log quotation:
 ...
> The reason:
> 
> MPC5121 FEC requires 4-byte alignment for TX data buffer and calls
> tx_skb_align_workaround() for copying sk_buff with not aligned .data to a new
> sk_buff with aligned one. But tx_skb_align_workaround() uses
> skb_copy_from_linear_data() which doesn't work for non-linear sk_buff:
> a new sk_buff has non-zero nr_frags and zero .data_len.
> 
> So improve the condition of calling tx_skb_align_workaround() and use
> skb_linearize() in it.
> 
> Signed-off-by: Alexander Popov <alex.popov@linux.com>

Applied, thanks.
