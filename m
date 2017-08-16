From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 1/3] tap: use build_skb() for small packet
Date: Wed, 16 Aug 2017 09:30:54 -0700 (PDT)
Message-ID: <20170816.093054.959220457289425520.davem@davemloft.net>
References: <20170816065837-mutt-send-email-mst@kernel.org>
        <3b24805d-b489-2dfc-f930-0518ba1a6ea0@redhat.com>
        <3b66193a-2df1-0191-0785-20123e38460a@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kubakici@wp.pl
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3b66193a-2df1-0191-0785-20123e38460a@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 16 Aug 2017 17:17:45 +0800

> It looks like full page allocation just produce too much stress on the
> page allocator.
> 
> I get 1.58Mpps (full page) vs 1.95Mpps (page frag) with the patches
> attached.

Yes, this is why drivers doing XDP tend to drift towards implementing
a local cache of pages.
