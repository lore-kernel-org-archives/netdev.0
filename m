From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [EXPERIMENTAL PATCH] 2.4 tulip jumbo frames
Date: Tue, 9 Dec 2003 22:32:18 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031209223214.A1855@sygehus.dk>
References: <20031209160632.D1345@sygehus.dk> <3FD5FC36.5090405@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3FD5FC36.5090405@pobox.com>; from jgarzik@pobox.com on Tue, Dec 09, 2003 at 11:45:42AM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Dec 09, 2003 at 11:45:42AM -0500, Jeff Garzik wrote:
> Two questions and a comment...
> 
> Would you split this into two patches?  The first simply adds, and uses, 
> tp->rx_buf_sz.  The second adds PKT_BUF_SZ_MAX and mtu-related changes.

That sounds like a good idea. I'll do that.
I tried to find a good place in the private structure to add the rx_buf_sz
field. By good, I mean using the cache efficiently. Any comments about that?

> Have you looked at Donald Becker's changes to tulip.c?  He went through 
> most of his drivers and made the changes necessary to support larger 
> MTUs.  IIRC his tulip.c changes (which should be easily translate-able 
> to 2.6.x tulip) were a bit more minimal than your patch, but still 
> served the purpose.

I have not looked at this particular part of Becker's tulip.c. I'll have a
look at it.

> For the comment:  I am curious why a VLAN_xxx constant is included in 
> the calculation of max MTU, in the ->change_mtu hook?

This is to ensure that the receive buffers are large enough to hold a frame
of the requested MTU also when using VLAN tags.

> IMO ->change_mtu 
> simply needs to bind the MTU to the min and max h/w limits.  If 
> VLAN_ETH_HLEN ever figures into the calculations, those calculations 
> should occur elsewhere, not in ->change_mtu.

What do you propose? Do we need something like

int vlan_adjust_mtu (int mtu)
{
#ifdef CONFIG_VLANN_8021Q
	return (mtu - VLAN_HLEN);
#else
	return (mtu);
#endif
}

and

int foobar_change_mtu (struct net_device *dev, int mtu)
{
	mtu = vlan_adjust_mtu (mtu);
	/* check hardware limits. */
	...
	dev->mtu = mtu;
	return (0);
}

? Ben, this would also keep you happy, right?

-- 
Regards,
Rask Ingemann Lambertsen
