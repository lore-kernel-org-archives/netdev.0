From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ofa-general] Re: [PATCH 11/12 -Rev2] IPoIB xmit API addition
Date: Mon, 23 Jul 2007 14:48:26 +0400
Message-ID: <20070723104826.GD22877@2ka.mipt.ru>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070722090649.7787.47960.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	mcarlson@broadcom.com, kaber@trash.net, jeff@garzik.org,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	tgraf@suug.ch, hadi@cyberus.ca, davem@davemloft.net,
	mchan@broadcom.com, sri@us.ibm.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070722090649.7787.47960.sendpatchset@K50wks273871wss.in.ibm.com>
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

On Sun, Jul 22, 2007 at 02:36:49PM +0530, Krishna Kumar (krkumar2@in.ibm.com) wrote:
> diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib_ib.c rev2/drivers/infiniband/ulp/ipoib/ipoib_ib.c
> --- org/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2007-07-20 07:49:28.000000000 +0530
> +++ rev2/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2007-07-22 00:08:37.000000000 +0530
> @@ -242,8 +242,9 @@ repost:
>  static void ipoib_ib_handle_tx_wc(struct net_device *dev, struct ib_wc *wc)
>  {
>  	struct ipoib_dev_priv *priv = netdev_priv(dev);
> +	int i = 0, num_completions;
> +	int tx_ring_index = priv->tx_tail & (ipoib_sendq_size - 1);
>  	unsigned int wr_id = wc->wr_id;
> -	struct ipoib_tx_buf *tx_req;
>  	unsigned long flags;
>  
>  	ipoib_dbg_data(priv, "send completion: id %d, status: %d\n",
> @@ -255,23 +256,57 @@ static void ipoib_ib_handle_tx_wc(struct
>  		return;
>  	}
>  
> -	tx_req = &priv->tx_ring[wr_id];
> +	num_completions = wr_id - tx_ring_index + 1;
> +	if (num_completions <= 0)
> +		num_completions += ipoib_sendq_size;

Can this still be less than zero?

-- 
	Evgeniy Polyakov
