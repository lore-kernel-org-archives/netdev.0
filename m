From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.4.28-pre3] 3c59x: resync with 2.6
Date: Fri, 8 Oct 2004 14:29:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008142959.H14378@tuxdriver.com>
References: <20041008121307.C14378@tuxdriver.com> <4166E501.4000708@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, akpm@osdl.org,
        marcelo.tosatti@cyclades.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4166E501.4000708@pobox.com>; from jgarzik@pobox.com on Fri, Oct 08, 2004 at 03:05:37PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 08, 2004 at 03:05:37PM -0400, Jeff Garzik wrote:
> John W. Linville wrote:
> 
> >  static struct ethtool_ops vortex_ethtool_ops = {
> > -	.get_drvinfo		= vortex_get_drvinfo,
> > +	.get_drvinfo =		vortex_get_drvinfo,
> >  };
> 
> reverting good style.

Hey, I'm not the one who put it in 2.6... :-)

I can fix it, then submit a 2.6 patch as well?

> >  	case SIOCSMIIREG:		/* Write MII PHY register. */
> > -	case SIOCDEVPRIVATE+2:		/* for binary compat, remove in 2.5 */
> 
> breaks ABI in the middle of a stable series

Good point...

> > +static inline struct mii_ioctl_data *if_mii(struct ifreq *rq)
> > +{
> > +	return (struct mii_ioctl_data *) &rq->ifr_ifru;
> > +}
> > +
> > +
> 
> This should be in include/linux/mii.h like it is in 2.6.x.

I think you missed this part:

> > --- linux-2.4/include/linux/mii.h.orig
> > +++ linux-2.4/include/linux/mii.h
> > @@ -9,6 +9,7 @@
> > #define __LINUX_MII_H__

The patch must have been too long... :-)

I'll cook-up another version, plus the tiny 2.6 patch as well...

John
-- 
John W. Linville
linville@tuxdriver.com
