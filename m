From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] bnxt_en: New Broadcom ethernet driver.
Date: Sun, 18 Oct 2015 22:21:50 -0700
Message-ID: <20151018222150.427d5311@xeon-e3>
References: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <prashant@broadcom.com>,
	<eddie.wai@broadcom.com>, <huangjw@broadcom.com>,
	<netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33325 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbbJSFVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 01:21:52 -0400
Received: by pabrc13 with SMTP id rc13so179610293pab.0
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 22:21:52 -0700 (PDT)
In-Reply-To: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 Oct 2015 00:21:44 -0400
Michael Chan <mchan@broadcom.com> wrote:

> +static inline u32 bnxt_tx_avail(struct bnxt *bp, struct bnxt_tx_ring_info *txr)
> +{
> +	/* Tell compiler to fetch tx indices from memory. */
> +	barrier();

Actually, you are telling compiler not to reorder. Which may not
be sufficient on some platforms. 


> +	return bp->tx_ring_size -
> +		((txr->tx_prod - txr->tx_cons) & bp->tx_ring_mask);
> +}
