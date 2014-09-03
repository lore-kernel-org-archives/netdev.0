From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH 1/2] net-timestamp: Merge shared code between phy and
 regular timestamping
Date: Wed, 3 Sep 2014 14:50:33 -0400
Message-ID: <CA+FuTScKSoEzTPpEEz8o8puiFbXgUnrk4q12W4eDBBPqX+EpXg@mail.gmail.com>
References: <20140903155022.1896.59030.stgit@ahduyck-bv4.jf.intel.com> <20140903155351.1896.54047.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:50329 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbaICSvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 14:51:05 -0400
Received: by mail-qg0-f41.google.com with SMTP id i50so8893745qgf.14
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 11:51:03 -0700 (PDT)
In-Reply-To: <20140903155351.1896.54047.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +}
> +EXPORT_SYMBOL_GPL(skb_complete_tx_timestamp);
> +
> +void __skb_tstamp_tx(struct sk_buff *orig_skb,
> +                    struct skb_shared_hwtstamps *hwtstamps,
> +                    struct sock *sk, int tstype)
> +{
> +       struct sk_buff *skb;
> +
> +       if (!sk)
> +               return;
> +
> +       /*
> +        * no hardware time stamps available,
> +        * so keep the shared tx_flags and only
> +        * store software time stamp
> +        */

This comment only makes sense within the else {} clause. As a matter
of fact, I'd just drop it. The patch also inverts the branch. I would
keep the original order, as that is also the order in
skb_complete_tx_timestamp.

> +       if (!hwtstamps)
> +               orig_skb->tstamp = ktime_get_real();
> +       else
> +               *skb_hwtstamps(orig_skb) = *hwtstamps;
> +

Otherwise looks great to me. The code deduplicates shared code between
__skb_tstamp_tx and skb_complete_timestamp without introduces logical
changes to either codepath.
