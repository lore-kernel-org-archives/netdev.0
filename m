From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 6/6] Modify tag_ksz.c to support other KSZ switch
 drivers
Date: Tue, 19 Sep 2017 00:42:36 +0200
Message-ID: <20170918224236.GB29615@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121901@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121A22@CHN-SV-EXMX02.mchp-main.com>
 <20170907214834.GT11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D2E@CHN-SV-EXMX02.mchp-main.com>
 <20170918195708.GE15606@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D7C@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41124D7C@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2017 at 08:55:17PM +0000, Tristram.Ha@microchip.com wrote:
> > > > This is ugly. We have a clean separation between a switch driver and a
> > > > tag driver. Here you are mixing them together. Don't. Look at the
> > > > mailing lists for what Florian and I suggested to Pavel. It will also
> > > > solve your include file issue above.
> > >
> > > It seems to me all tag_*.c are hard-coded.  They do not have access to
> > > the switch device and just use the bit definitions defined in the top to
> > > do the job.
> > >
> > > This creates a problem for all KSZ switch devices as they have different
> > > tail tag formats and lengths.  There will be potentially 4 additional
> > > DSA_TAG_PROT_KSZ* just to handle them.  Extra files will be added
> > > with about the same code.
> > 
> > Hi Tristram
> > 
> > Think about factoring out the common code into a shared functions.
> >
> 
> I am a little unsure what you have in mind.  Can you elaborate?

You say you need 4 DSA_TAG_PROT_KSZ. I guess the code is nearly
identical in them all? If i remember correctly, the two tag bytes are
the other way around?

static int ksz8k_xmit( *skb, struct net_device *dev)
{
	uint8* tag;

	tag = ksz_xmit(skb, dev)
	if (!tag)
	     return NULL;

	tag[0] = 1 << p->dp->index;
	tag[1] = 0;

	return skb;
}

static int ksz9k_xmit( *skb, struct net_device *dev)
{
	uint8* tag;

	tag = ksz_xmit(skb, dev)
	if (!tag)
	     return NULL;

	tag[0] = 0;
	tag[1] = 1 << p->dp->index;

	return skb;
}

const struct dsa_device_ops ksz8k_netdev_ops = {
       .xmit   = ksz8k_xmit,
       .rcv    = ksz8k_rcv,
};

const struct dsa_device_ops ksz9k_netdev_ops = {
       .xmit   = ksz9k_xmit,
       .rcv    = ksz9k_rcv,
};

	Andrew
