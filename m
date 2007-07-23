From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 03/12 -Rev2] dev.c changes.
Date: Mon, 23 Jul 2007 16:47:25 +0530
Message-ID: <OFC6146D85.364CF696-ON65257321.003B4D10-65257321.003E0550@in.ibm.com>
References: <20070723104428.GC22877@2ka.mipt.ru>
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
In-Reply-To: <20070723104428.GC22877@2ka.mipt.ru>
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

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote on 07/23/2007 04:14:28 PM:
> > +/*
> > + * dev_change_tx_batching - Enable or disable batching for a driver
that
> > + * supports batching.

> > +   /* Check if new value is same as the current */
> > +   if (!!(dev->features & NETIF_F_BATCH_ON) == !!new_batch_skb)
> > +      goto out;
>
> o_O
>
> Scratched head for too long before understood what it means :)

Is there a easy way to do this ?

> > +   spin_lock(&dev->queue_lock);
> > +   if (new_batch_skb) {
> > +      dev->features |= NETIF_F_BATCH_ON;
> > +      dev->tx_queue_len >>= 1;
> > +   } else {
> > +      if (!skb_queue_empty(&dev->skb_blist))
> > +         skb_queue_purge(&dev->skb_blist);
> > +      dev->features &= ~NETIF_F_BATCH_ON;
> > +      dev->tx_queue_len <<= 1;
> > +   }
> > +   spin_unlock(&dev->queue_lock);
>
> Hmm, should this also stop interrupts?

That is a good question, and I am not sure. I thought it
is not required, though adding it doesn't affect code
either. Can someone tell if disabling bh is required and
why (couldn't figure out the intention of bh for
dev_queue_xmit either, is this to disable preemption) ?

Thanks,

- KK
