From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 02/12 -Rev2] Changes to netdevice.h
Date: Mon, 23 Jul 2007 08:27:53 +0530
Message-ID: <OFFAB073E4.487DACF3-ON65257321.00101BE3-65257321.00104971@in.ibm.com>
References: <46A38EAB.6050300@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, davem@davemloft.net, sri@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46A38EAB.6050300@trash.net>
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

Hi Patrick,

Patrick McHardy <kaber@trash.net> wrote on 07/22/2007 10:36:51 PM:

> Krishna Kumar wrote:
> > @@ -472,6 +474,9 @@ struct net_device
> >     void         *priv;   /* pointer to private data   */
> >     int         (*hard_start_xmit) (struct sk_buff *skb,
> >                        struct net_device *dev);
> > +   int         (*hard_start_xmit_batch) (struct net_device
> > +                       *dev);
> > +
>
>
> Os this function really needed? Can't you just call hard_start_xmit with
> a NULL skb and have the driver use dev->blist?

Probably not. I will see how to do it this way and get back to you.

> >     /* These may be needed for future network-power-down code. */
> >     unsigned long      trans_start;   /* Time (in jiffies) of last Tx
*/
> >
> > @@ -582,6 +587,8 @@ struct net_device
> >  #define   NETDEV_ALIGN      32
> >  #define   NETDEV_ALIGN_CONST   (NETDEV_ALIGN - 1)
> >
> > +#define BATCHING_ON(dev)   ((dev->features & NETIF_F_BATCH_ON) != 0)
> > +
> >  static inline void *netdev_priv(const struct net_device *dev)
> >  {
> >     return dev->priv;
> > @@ -832,6 +839,8 @@ extern int      dev_set_mac_address(struct n
> >                     struct sockaddr *);
> >  extern int      dev_hard_start_xmit(struct sk_buff *skb,
> >                     struct net_device *dev);
> > +extern int      dev_add_skb_to_blist(struct sk_buff *skb,
> > +                    struct net_device *dev);
>
>
> Again, function signatures should be introduced in the same patch
> that contains the function. Splitting by file doesn't make sense.

Right. I did it for some but missed this. Sorry, will redo.

thanks,

- KK
