From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net v4 3/4] r8152: support stopping/waking tx queue
Date: Wed, 20 Nov 2013 14:30:56 +0800
Message-ID: <F013653E0841424DB3B68A223B07962D@realtek.com.tw>
References: <1384831511-1625-4-git-send-email-hayeswang@realtek.com><20131119.152536.146706009595105149.davem@davemloft.net><9C2E97E7BED9426ABE0FF4F63E12E33D@realtek.com.tw> <20131120.002223.1492430030566522391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, 'nic_swsd' <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131120.002223.1492430030566522391.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 David Miller [mailto:davem@davemloft.net] 
[...]
> > If the situation occurs, it means there is no tx buffer at 
> that time. If the
> > netif_wake_queue() is called, only one more packet would be 
> queued and the tx
> > queue would be stopped again after calling 
> rtl8152_start_xmit(). That is, it
> > is not necessary to wake the queue. Besides, after the tx 
> is completed, another
> > tasklet would be scheduled if there is any packet which is 
> queued in the list.
> > That is, the r8152_tx_agg_fill() would be called and the 
> netif_queue_stopped()
> > would be check againg, so the tx queue would not be stopped forever.
> 
> Then the queue can be woken when in fact r8152_start_xmit() 
> is not able to
> actually queue packets.  It is just as equally problematic.
> 
> You have to synchronize this state, somehow.
> 
> tg3 driver does this by taking netif tx queue lock during the wake
> test sequence in TX reclaim.  This works because ->ndo_start_xmit() is
> run with this lock held.

Thanks for your answer. I would modify it.
