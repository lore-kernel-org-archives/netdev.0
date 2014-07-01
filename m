From: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Subject: Re: [PATCH RFC V2 2/2] net: qualcomm: new Ethernet over SPI driver
 for QCA7000
Date: Tue, 1 Jul 2014 19:16:01 +0100
Message-ID: <20140701181601.GA11399@leverpostej>
References: <1404232609-4314-1-git-send-email-stefan.wahren@i2se.com>
 <1404232609-4314-3-git-send-email-stefan.wahren@i2se.com>
 <20140701174616.GA10927@leverpostej>
 <1404237465.14624.9.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <Pawel.Moll-5wv7dgnIgG8@public.gmane.org>,
	"ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org" <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	"galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1404237465.14624.9.camel@joe-AO725>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 01, 2014 at 06:57:45PM +0100, Joe Perches wrote:
> On Tue, 2014-07-01 at 18:46 +0100, Mark Rutland wrote:
> > On Tue, Jul 01, 2014 at 05:36:49PM +0100, Stefan Wahren wrote:
> > > This patch adds the Ethernet over SPI driver for the
> > > Qualcomm QCA7000 HomePlug GreenPHY.
> []
> > > +               memcpy(qca->net_dev->dev_addr, mac, ETH_ALEN);
> > 
> > I believe that it is preferred to write:
> > 
> > 	ether_addr_copy(qca->net_dev->dev_addr, mac);
> > 
> > I believe checkpatch has a warning for this.
> 
> True, but you have to make sure that both args are
> at least __aligned(2) and afaics there's no
> guarantee that's true for mac.

In this case I think there is, though I deleted the context that would
make that clearer. Sorry about that.

We acquired mac with:

	mac = of_get_mac_address(spi_device->dev.of_node);

Where of_get_mac_address returns a property::value pointer.

As far as I can tell, when we unflatten the DT each property::value is
pointed at the original data in the DTB. Each data stream immediately
follows a naturally aligned 32-bit FDT_PROP token in the DTB, so all
value pointers should be aligned to at least 4 bytes.

That all said I'm happy to just use memcpy if we're not happy to rely on
the DTB format, it's not exactly going to be a bottleneck.

Cheers,
Mark.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
