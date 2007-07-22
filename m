From: Patrick McHardy <kaber@trash.net>
Subject: [ofa-general] Re: [PATCH 02/12 -Rev2] Changes to netdevice.h
Date: Sun, 22 Jul 2007 19:06:51 +0200
Message-ID: <46A38EAB.6050300@trash.net>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070722090516.7787.79695.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org, tgraf@suug.ch, jeff@garzik.org,
	sri@us.ibm.com, hadi@cyberus.ca, davem@davemloft.net, mchan@broadcom.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070722090516.7787.79695.sendpatchset@K50wks273871wss.in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Krishna Kumar wrote:
> @@ -472,6 +474,9 @@ struct net_device
>  	void			*priv;	/* pointer to private data	*/
>  	int			(*hard_start_xmit) (struct sk_buff *skb,
>  						    struct net_device *dev);
> +	int			(*hard_start_xmit_batch) (struct net_device
> +							  *dev);
> +


Os this function really needed? Can't you just call hard_start_xmit with
a NULL skb and have the driver use dev->blist?

>  	/* These may be needed for future network-power-down code. */
>  	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
>  
> @@ -582,6 +587,8 @@ struct net_device
>  #define	NETDEV_ALIGN		32
>  #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
>  
> +#define BATCHING_ON(dev)	((dev->features & NETIF_F_BATCH_ON) != 0)
> +
>  static inline void *netdev_priv(const struct net_device *dev)
>  {
>  	return dev->priv;
> @@ -832,6 +839,8 @@ extern int		dev_set_mac_address(struct n
>  					    struct sockaddr *);
>  extern int		dev_hard_start_xmit(struct sk_buff *skb,
>  					    struct net_device *dev);
> +extern int		dev_add_skb_to_blist(struct sk_buff *skb,
> +					     struct net_device *dev);


Again, function signatures should be introduced in the same patch
that contains the function. Splitting by file doesn't make sense.
