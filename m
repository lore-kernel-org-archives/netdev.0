From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH] bond: Don't set skb->queue_mapping in netpoll.
Date: Thu, 15 Aug 2013 18:35:30 +0800
Message-ID: <1376562930.2626.16.camel@cr0>
References: <1376555808-6531-1-git-send-email-tm@tao.ma>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Tao Ma <tm@tao.ma>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376555808-6531-1-git-send-email-tm@tao.ma>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-08-15 at 16:36 +0800, Tao Ma wrote:
> From: Tao Ma <boyu.mt@taobao.com>
> 
> When we are using netpoll, we don't go through the normal
> transmit process. In this case, bond_select_queue is not called
> and qdisc_skb_cb(skb)->slave_dev_queue_mapping isn't set.
> 

Yes?

In netpoll_send_skb_on_dev() we have:

        if (skb_queue_len(&npinfo->txq) == 0 && !
netpoll_owner_active(dev)) {
                struct netdev_queue *txq;

                txq = netdev_pick_tx(dev, skb);
                ...

where netdev_pick_tx() will call ->ndo_select_queue().
