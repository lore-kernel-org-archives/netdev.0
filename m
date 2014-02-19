From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 12/14] r8152: replace netif_rx withnetif_receive_skb
Date: Wed, 19 Feb 2014 11:01:51 +0800
Message-ID: <79F93FE4FECD48E7B7B6C6EE93151CB6@realtek.com.tw>
References: <1392731351-25502-1-git-send-email-hayeswang@realtek.com> <1392731351-25502-13-git-send-email-hayeswang@realtek.com> <20140218232850.GB13394@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140218232850.GB13394@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Wednesday, February 19, 2014 7:29 AM
> To: Hayes Wang
> Cc: netdev@vger.kernel.org; nic_swsd@realtek.com; 
> linux-kernel@vger.kernel.org; linux-usb@vger.kernel.org
> Subject: Re: [PATCH net-next 12/14] r8152: replace netif_rx 
> withnetif_receive_skb
> 
> Hayes Wang <hayeswang@realtek.com> :
> > Replace netif_rx with netif_receive_skb to avoid disabling irq frequently
> > for increasing the efficiency.
> 
> read_bulk_callback is issued in irq context. It could thus use plain
> spin_lock / spin_unlock instead of the irq disabling version.

The rx_bottom() is called in tasklet, so I just think I could use
netif_receive_skb directly. The netif_rx seems to queue the packet,
and local_irq_disable() would be called before dequeuing the skb.
 
Best Regards,
Hayes
