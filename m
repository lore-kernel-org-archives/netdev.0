From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [RFC 4/4] [flexcan] Add support for FLEXCAN_DEBUG
Date: Fri, 5 Aug 2011 09:01:10 -0500
Message-ID: <20110805140110.GI4926@sgi.com>
References: <1312509979-13226-1-git-send-email-holt@sgi.com>
	<1312509979-13226-5-git-send-email-holt@sgi.com>
	<4E3B98B6.4040003@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E3B98B6.4040003-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On Fri, Aug 05, 2011 at 09:16:06AM +0200, Marc Kleine-Budde wrote:
> On 08/05/2011 04:06 AM, Robin Holt wrote:
> > Add a wrapper function for a register dump when a developer defines
> > FLEXCAN_DEBUG
> 
> Comments inline..however I'm not sure if we need this patch.

I really do like the ability to dump the registers.  It has come in handy
a couple of times while bringing up the board.  I do not know how hard
I would push for them, but I do not see them as having much down side
and I do know they have proven useful for me.

At this point, I have interpretted both your's and Wolfgang's comment as
a suggestion.  I do not know how this group of developers works and if
I should be taking that suggestion as a dope-slap indicating I should
drop this right now because I am an idiot or if the patch just leaves
a bad taste in your mouth.  Would either or both of you please clarify.

> > +#if defined(FLEXCAN_DEBUG)
> > +void _flexcan_reg_dump(struct net_device *dev, const char *file, int line,
> > +		       const char *func)
> > +{
> > +	const struct flexcan_priv *priv = netdev_priv(dev);
> > +	struct flexcan_regs __iomem *regs = priv->base;
> > +
> > +	printk(KERN_INFO "flexcan_reg_dump:%s:%d:%s()\n", file, line, func);
> 
> Use netdev_$LEVEL, please.
> If you use dbg, you can remove the ifdef altogether.

I assume you mean netdev_dbg.  If that were the case, then setting
CONFIG_CAN_DEBUG_DEVICES would bring these printks back and that was
explicitly stated as undesirable.  Am I understanding this wrong?

If not, I am going to fall back to netdev_info instead and leave the
#ifdef FLEXCAN_DEBUG.  Will that work?

Thanks,
Robin
