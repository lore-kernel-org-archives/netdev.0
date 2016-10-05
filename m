From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net 0/2] mlxsw: Couple of fixes
Date: Wed, 5 Oct 2016 13:14:51 +0200
Message-ID: <20161005111451.GB2293@nanopsycho>
References: <1475567165-3362-1-git-send-email-jiri@resnulli.us>
 <20161004.202927.1650578832896717724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32811 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752328AbcJELOy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 07:14:54 -0400
Received: by mail-wm0-f66.google.com with SMTP id p138so24027551wmb.0
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2016 04:14:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161004.202927.1650578832896717724.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 05, 2016 at 02:29:27AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Tue,  4 Oct 2016 09:46:03 +0200
>
>> Couple of fixes from Yotam.
>
>Series applied, thanks.
>
>Note that needed_headroom is a request, rather than a guarantee, so you
>may in some rare cases need to realloc your headroom if the kernel was
>not able to meet your request.

We already do that: 

        if (unlikely(skb_headroom(skb) < MLXSW_TXHDR_LEN)) {
                struct sk_buff *skb_orig = skb;

                skb = skb_realloc_headroom(skb, MLXSW_TXHDR_LEN);
                if (!skb) {
                        this_cpu_inc(mlxsw_sp_port->pcpu_stats->tx_dropped);
                        dev_kfree_skb_any(skb_orig);
                        return NETDEV_TX_OK;
                }
        }
