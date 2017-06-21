From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] udp: prefetch rmem_alloc in udp_queue_rcv_skb()
Date: Wed, 21 Jun 2017 18:07:37 +0200
Message-ID: <1498061257.2799.15.camel@redhat.com>
References: <ec963336242664e99c2f47f399c621aa7f5e2885.1498033422.git.pabeni@redhat.com>
         <20170621.114155.502883498671476879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56806 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752942AbdFUQW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 12:22:59 -0400
In-Reply-To: <20170621.114155.502883498671476879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-21 at 11:41 -0400, David Miller wrote:
> From: Paolo Abeni <pabeni@redhat.com>
> Date: Wed, 21 Jun 2017 10:24:40 +0200
> 
> > On UDP packets processing, if the BH is the bottle-neck, it
> > always sees a cache miss while updating rmem_alloc; try to
> > avoid it prefetching the value as soon as we have the socket
> > available.
> > 
> > Performances under flood with multiple NIC rx queues used are
> > unaffected, but when a single NIC rx queue is in use, this
> > gives ~10% performance improvement.
> > 
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> 
> Applied, but what about ipv6?

You are right, that was unintentionally left out. I'll do some tests
and send another patch for ipv6, too.

Thanks,

Paolo
