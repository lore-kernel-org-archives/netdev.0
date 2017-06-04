From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH] net/{mii,smsc}: Make mii_ethtool_get_link_ksettings and
 smc_netdev_get_ecmd return void
Date: Sun, 4 Jun 2017 22:49:06 +0300
Message-ID: <20170604194905.GA7045@yuvallap>
References: <20170604172200.4177-1-yuval.shaia@oracle.com>
 <20170604190133.GB10273@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, linux-usb@vger.kernel.org, shchers@gmail.com,
 stephen.boyd@linaro.org, paul.gortmaker@windriver.com, edumazet@google.com,
 jeremy.linton@arm.com, robert.jarzmik@free.fr, gerg@linux-m68k.org,
 f.fainelli@gmail.com, arnd@arndb.de, cooldavid@cooldavid.org, jarod@redhat.com,
 intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
 romieu@fr.zoreil.com, jay.vosburgh@canonical.com, tklauser@distanz.ch,
 hayeswang@realtek.com, allan@asix.com.tw, nic_swsd@realtek.com,
 mcuos.com@gmail.com, mario_limonciello@dell.com, rmk+kernel@armlinux.org.uk,
 pcnet32@frontier.com, green.hu@gmail.com, chris.roth@usask.ca,
 linux-arm-kernel@lists.infradead.org, klassert@mathematik.tu-chemnitz.de,
 linux-parisc@vger.kernel.org, nico@fluxnic.net, netdev@vger.kernel.org,
 oneukum@suse.com, ralf@linux-mips.org, stephen@networkplumber.org,
 hsweeten@visionengravers.com, fgao@4
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20170604190133.GB10273@lunn.ch>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 04, 2017 at 09:01:33PM +0200, Andrew Lunn wrote:
> > diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
> > index da02041..017f48c 100644
> > --- a/drivers/net/cris/eth_v10.c
> > +++ b/drivers/net/cris/eth_v10.c
> > @@ -1417,10 +1417,9 @@ static int e100_get_link_ksettings(struct net_device *dev,
> >  {
> >  	struct net_local *np = netdev_priv(dev);
> >  	u32 supported;
> > -	int err;
> >  
> >  	spin_lock_irq(&np->lock);
> > -	err = mii_ethtool_get_link_ksettings(&np->mii_if, cmd);
> > +	mii_ethtool_get_link_ksettings(&np->mii_if, cmd);
> >  	spin_unlock_irq(&np->lock);
> >  
> >  	/* The PHY may support 1000baseT, but the Etrax100 does not.  */
> > @@ -1432,7 +1431,7 @@ static int e100_get_link_ksettings(struct net_device *dev,
> >  	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
> >  						supported);
> >  
> > -	return err;
> > +	return 0;
> >  }
> 
> How far are going planning on going? It seems like
> *_get_link_ksettings() now all return a useless 0. Do you plan to
> change ethtool_ops and make if void all the way up?

It is not always correct, see for example how xgene_get_link_ksettings
returns non-zero value so i assume that ethtool_ops should remain as it is.
Also, looking at ethtool_get_settings it seems that returned value is
checked.

> 
>        Andrew
