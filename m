From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH] net/dec: Make __de_get_link_ksettings return void
Date: Sun, 4 Jun 2017 22:52:42 +0300
Message-ID: <20170604195241.GB7045@yuvallap>
References: <20170604170851.3808-1-yuval.shaia@oracle.com>
 <4391c380-f7f6-d549-a225-716b9b9df664@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jarod@redhat.com, tklauser@distanz.ch,
        tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-parisc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4391c380-f7f6-d549-a225-716b9b9df664@cogentembedded.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 04, 2017 at 08:22:05PM +0300, Sergei Shtylyov wrote:
> Hello!
> 
> On 6/4/2017 8:08 PM, Yuval Shaia wrote:
> 
> > Make return value void since function never return meaningfull value
> 
>   You only make 1 of 2 functions void. It looks like there should be 2 patches.

And what would be the second function?

> 
> > 
> > Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>
> > ---
> >  drivers/net/ethernet/dec/tulip/de2104x.c | 11 ++++-------
> >  1 file changed, 4 insertions(+), 7 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
> > index 91b8f6f..c87b8cc 100644
> > --- a/drivers/net/ethernet/dec/tulip/de2104x.c
> > +++ b/drivers/net/ethernet/dec/tulip/de2104x.c
> > @@ -1483,8 +1483,8 @@ static void __de_get_regs(struct de_private *de, u8 *buf)
> >  	de_rx_missed(de, rbuf[8]);
> >  }
> > 
> > -static int __de_get_link_ksettings(struct de_private *de,
> > -				   struct ethtool_link_ksettings *cmd)
> > +static void __de_get_link_ksettings(struct de_private *de,
> > +				    struct ethtool_link_ksettings *cmd)
> >  {
> >  	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
> >  						de->media_supported);
> > @@ -1517,8 +1517,6 @@ static int __de_get_link_ksettings(struct de_private *de,
> >  		cmd->base.autoneg = AUTONEG_ENABLE;
> > 
> >  	/* ignore maxtxpkt, maxrxpkt for now */
> > -
> > -	return 0;
> >  }
> > 
> >  static int __de_set_link_ksettings(struct de_private *de,
> > @@ -1615,13 +1613,12 @@ static int de_get_link_ksettings(struct net_device *dev,
> >  				 struct ethtool_link_ksettings *cmd)
> >  {
> >  	struct de_private *de = netdev_priv(dev);
> > -	int rc;
> > 
> >  	spin_lock_irq(&de->lock);
> > -	rc = __de_get_link_ksettings(de, cmd);
> > +	__de_get_link_ksettings(de, cmd);
> >  	spin_unlock_irq(&de->lock);
> > 
> > -	return rc;
> > +	return 0;
> >  }
> > 
> >  static int de_set_link_ksettings(struct net_device *dev,
> > 
> 
> MBR, Sergei
> 
