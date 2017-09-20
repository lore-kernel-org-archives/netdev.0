From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH] net: Introduce a socket option to enable picking tx queue based on rx queue.
Date: Wed, 20 Sep 2017 17:30:47 +0200
Message-ID: <87vakdbd5k.fsf@stressinduktion.org>
References: <1504222032-6337-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:60299 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751507AbdITPaw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 11:30:52 -0400
In-Reply-To: <1504222032-6337-1-git-send-email-sridhar.samudrala@intel.com>
        (Sridhar Samudrala's message of "Thu, 31 Aug 2017 16:27:12 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sridhar Samudrala <sridhar.samudrala@intel.com> writes:

> This patch introduces a new socket option SO_SYMMETRIC_QUEUES that can be used
> to enable symmetric tx and rx queues on a socket.
>
> This option is specifically useful for epoll based multi threaded workloads
> where each thread handles packets received on a single RX queue . In this model,
> we have noticed that it helps to send the packets on the same TX queue
> corresponding to the queue-pair associated with the RX queue specifically when
> busy poll is enabled with epoll().
>
> Two new fields are added to struct sock_common to cache the last rx ifindex and
> the rx queue in the receive path of an SKB. __netdev_pick_tx() returns the cached
> rx queue when this option is enabled and the TX is happening on the same device.

Would it help to make the rx and tx skb hashes symmetric
(skb_get_hash_symmetric) on request?
