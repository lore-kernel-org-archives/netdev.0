From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 1/2] net: use cmpxchg instead of spinlock in ptr rings
Date: Tue, 15 Nov 2016 16:30:57 +0200
Message-ID: <20161115162701-mutt-send-email-mst@kernel.org>
References: <20161115143258.2c46fc9a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49166 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753152AbcKOOa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 09:30:58 -0500
Content-Disposition: inline
In-Reply-To: <20161115143258.2c46fc9a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2016 at 02:32:58PM +0100, Jesper Dangaard Brouer wrote:
> What I would really like to see is a lock-free (locked cmpxchg) queue
> implementation, what like ptr_ring use the array as empty/full check,
> and still (somehow) support bulking.

I think lock-free is overrated for this use-case - we hold the lock
for such a short amount of time.

I think what we want is just a simpler spinlock - one that's faster than
qlock for use-cases that are unfair anyway, like this one where even if
you get the lock in a fair way, FIFO might be full and you won't be able
to queue.

Or find an API to add to FIFO in a fair way.

-- 
MST
