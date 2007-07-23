From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 11/12 -Rev2] IPoIB xmit API addition
Date: Mon, 23 Jul 2007 16:47:45 +0530
Message-ID: <OF78ACF954.97C6291D-ON65257321.003BD95C-65257321.003E0CCE@in.ibm.com>
References: <20070723104826.GD22877@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, mcarlson@broadcom.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	davem@davemloft.net, sri@us.ibm.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070723104826.GD22877@2ka.mipt.ru>
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

Hi Evgeniy,

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote on 07/23/2007 04:18:26 PM:

> >  static void ipoib_ib_handle_tx_wc(struct net_device *dev, struct ib_wc
*wc)
> >  {
> >     struct ipoib_dev_priv *priv = netdev_priv(dev);
> > +   int i = 0, num_completions;
> > +   int tx_ring_index = priv->tx_tail & (ipoib_sendq_size - 1);
> >     unsigned int wr_id = wc->wr_id;
> > -   struct ipoib_tx_buf *tx_req;
> >     unsigned long flags;
> >
> >     ipoib_dbg_data(priv, "send completion: id %d, status: %d\n",
> > @@ -255,23 +256,57 @@ static void ipoib_ib_handle_tx_wc(struct
> >        return;
> >     }
> >
> > -   tx_req = &priv->tx_ring[wr_id];
> > +   num_completions = wr_id - tx_ring_index + 1;
> > +   if (num_completions <= 0)
> > +      num_completions += ipoib_sendq_size;
>
> Can this still be less than zero?

Should never happen, otherwise the TX code wrote on bad/unallocated
memory and would have crashed first.

Thanks,

- KK
