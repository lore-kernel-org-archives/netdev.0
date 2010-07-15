From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 1/2] bnx2: allocate with GFP_KERNEL flag on RX path
 init
Date: Thu, 15 Jul 2010 07:48:40 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B842BD26F@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20100715142537.12504.60051.send-patch@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "'Stanislaw Gruszka'" <sgruszka@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4161 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933380Ab0GOOsp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 10:48:45 -0400
In-Reply-To: <20100715142537.12504.60051.send-patch@dhcp-lab-109.englab.brq.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw Gruszka wrote:

> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---
> @@ -2974,7 +2974,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct
> bnx2_rx_ring_info *rxr, struct sk_buff *skb,
>       int err;
>       u16 prod = ring_idx & 0xffff;
>
> -     err = bnx2_alloc_rx_skb(bp, rxr, prod);
> +     err = bnx2_alloc_rx_skb(bp, rxr, prod, GFP_KERNEL);

This should be GFP_ATOMIC since it is called from NAPI softirq
context.


