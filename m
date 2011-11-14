From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] ndo: ndo_queue_xmit/ndo_flush_xmit (was Re: [RFC]
	[ver3 PATCH 0/6] Implement multiqueue virtio-net)
Date: Mon, 14 Nov 2011 18:21:49 +0200
Message-ID: <20111114162149.GA23024@redhat.com>
References: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
	<20111113174827.GA23310@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20111113174827.GA23310@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 13, 2011 at 07:48:28PM +0200, Michael S. Tsirkin wrote:
> @@ -863,6 +872,9 @@ struct net_device_ops {
>  	int			(*ndo_stop)(struct net_device *dev);
>  	netdev_tx_t		(*ndo_start_xmit) (struct sk_buff *skb,
>  						   struct net_device *dev);
> +	netdev_tx_t		(*ndo_queue_xmit)(struct sk_buff *skb,
> +						  struct net_device *dev);
> +	void			(*ndo_flush_xmit)(struct net_device *dev);
>  	u16			(*ndo_select_queue)(struct net_device *dev,
>  						    struct sk_buff *skb);
>  	void			(*ndo_change_rx_flags)(struct net_device *dev,
> @@ -2099,6 +2111,10 @@ extern int		dev_set_mac_address(struct net_device *,

An alternative I considered was to add a boolean flag to ndo_start_xmit
'bool queue' or something like this, plus ndo_flush_xmit.
This will lead to cleaner code I think but will require all drivers
to be changed, so for a proof of concept I decided to go for one
that is less work.

Let me know what looks more palatable ... 

-- 
MST
