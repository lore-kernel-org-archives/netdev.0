From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v4 net-next RFC] net: Generic XDP
Date: Fri, 14 Apr 2017 17:59:51 -0700
Message-ID: <20170415005949.GB73685@ast-mbp.thefacebook.com>
References: <20170413.120925.2082322246776478766.davem@davemloft.net>
 <CACKFLikm1vDzz8eQJMJOEsbv-NNV41ki2TEPVPCSpP6VjaowBA@mail.gmail.com>
 <20170413.162315.1889531431093534154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michael.chan@broadcom.com, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34837 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755930AbdDOA74 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 20:59:56 -0400
Content-Disposition: inline
In-Reply-To: <20170413.162315.1889531431093534154.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 04:23:15PM -0400, David Miller wrote:
> +
> +	switch (act) {
> +	case XDP_TX:
> +		__skb_push(skb, skb->mac_len);

s/skb->mac_len/mac_len/

> +	HARD_TX_UNLOCK(dev, txq);
> +	if (free_skb) {
> +		trace_xdp_exception(dev, xdp_prog, XDP_TX);
> +		kfree_skb(skb);

nice that you didn't forget to add trace_xdp_exception in this path :)

Overall looks good to me and other than the minor nit in tx, i think it
should work for programs already used with in-driver xdp.
I'll test it next week unless people beat me to it.
