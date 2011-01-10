From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2 1/2] can: add driver for Softing card
Date: Mon, 10 Jan 2011 14:31:12 +0100
Message-ID: <20110110133112.GA324@e-circ.dyndns.org>
References: <20110104150513.GA321@e-circ.dyndns.org>
	<20110104150759.GB321@e-circ.dyndns.org>
	<4D24DB2C.9040104@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D24DB2C.9040104-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Wolfgang,

A few thoughts ...

On Wed, Jan 05, 2011 at 09:57:16PM +0100, Wolfgang Grandegger wrote:
> >  
> >  obj-y				+= usb/
> > +obj-y				+= softing/
> 
> Please use "obj-$(CONFIG_CAN_SOFTING)" here.
As I explained, softing does not depend on softing_cs or vice versa,
which makes "obj-$(CONFIG_CAN_SOFTING)" not right.

> > +	if (type != 0xffff) {
> > +		dev_alert(&card->pdev->dev, "firware starts with type 0x%04x\n",
> 
> Typo?
> 
??

> > +
> > +int softing_default_output(struct net_device *netdev)
> > +{
> > +	struct softing_priv *priv = netdev_priv(netdev);
> > +	struct softing *card = priv->card;
> > +
> > +	switch (priv->chip) {
> > +	case 1000:
> > +		if (card->pdat->generation < 2)
> > +			return 0xfb;
> > +		return 0xfa;
> > +	case 5:
> > +		return 0x60;
> > +	default:
> > +		return 0x40;
> > +	}
> > +}
> 
> Again, some magic constants.
The thing is, I didn't create those number, nor do I precisely know
which are the right ones, or how I would name those.
Since they're used one, I tought this would work.
> 
> > +	ret = netif_rx(skb);
> > +	if (ret == NET_RX_DROP)
> > +		++netdev->stats.rx_dropped;
> 
> Hm, I wonder if all Socket-CAN drivers should handle the return value of
> netif_rx that way?
> 
No, they should not.
After a seconds look, I'm a tiny little bit wrong here.
I should only increment rx_dropped when it's a real received message,
and not a virtual constructed one (bus crtls).
I moved this thing to the rx data handler.
Maybe, a common CAN rx function is usefull to properly deal with
the can_echo_skb & friends.

> 
> > +	priv->can.ctrlmode_supported =
> > +		CAN_CTRLMODE_3_SAMPLES;/* | CAN_CTRLMODE_BERR_REPORTING */;
> 
> Hm, any chance to support CAN_CTRLMODE_BERR_REPORTING? If not, please
> remove the comment.

I think I better try to write it properly without, and add error reporting
later, after serious testing of the error reporting on a softing card.

The primary goal now is get this driver in mainline kernel since PCMCIA
has been changing recently, and I found it hard to keep up. So, first things
first ...


Kurt
