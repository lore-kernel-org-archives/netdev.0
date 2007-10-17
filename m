From: Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 9179] New: 2.6.23.1 / USB_ZD1201: Kernel
	panic with zd1201 driver
Date: Wed, 17 Oct 2007 20:49:29 -0200
Message-ID: <20071017224929.GB9773@ghostprotocols.net>
References: <bug-9179-10286@http.bugzilla.kernel.org/> <20071017132740.eebaed9d.akpm@linux-foundation.org> <1192654011.15090.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, zairasai-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1192654011.15090.3.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Em Wed, Oct 17, 2007 at 04:46:51PM -0400, Dan Williams escreveu:
> On Wed, 2007-10-17 at 13:27 -0700, Andrew Morton wrote:
> > On Wed, 17 Oct 2007 11:34:57 -0700 (PDT)
> > bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:
> > 
> > > http://bugzilla.kernel.org/show_bug.cgi?id=9179
> > > 
> > >            Summary: 2.6.23.1 / USB_ZD1201: Kernel panic with zd1201 driver
> > >            Product: Drivers
> > >            Version: 2.5
> > >      KernelVersion: 2.6.23.1
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: normal
> > >           Priority: P1
> > >          Component: network-wireless
> > >         AssignedTo: drivers_network-wireless-ztI5WcYan/vQLgFONoPN62D2FQJk+8+b@public.gmane.org
> > >         ReportedBy: zairasai-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org
> > > 
> > > 
> > > [1.] One line summary of the problem:
> > > 
> > > 2.6.23.1 / USB_ZD1201: Kernel panic with zd1201 driver
> > > 
> > > 
> > > 
> > > 
> > > [2.] Full description of the problem:
> > > 
> > > The zd1201-driver (symbol: USB_ZD1201) triggers a kernel panic during
> > > initialization of the WLAN device, showing the following message:
> > > 
> > > EIP: [<e095e1d1>] zd1201_usbrx+0x6e1/0xbb0 [zd1201] SS:ESP 0068:c0469d7c
> > > Kernel panic - not syncing: Fatal exception in interrupt
> > > 
> > > According to the init output during bootup, the panic seems to occur right when
> > > the WLAN device receives an IP address from the DHCP-Server of the
> > > WLAN/DSL-Router. The WLAN device is (in my case) a 'Belkin F5D6051' based on
> > > the ZyDAS 1201 chip.
> > > 
> > > As far as i know, the only recent change in 'drivers/net/wireless/zd1201.c' was
> > > done in patch-2.6.22, so the bug probably affects all kernel versions later
> > > than 2.6.21.7, but at least the ones i've tested (which are listed in the
> > > summary below). It also recently came up in some different
> > > distribution-specific forums/bugtrackers, so it does not seem to be specific to
> > > my machine/setup. A link to another report on this problem is included at the
> > > end of this report.
> > > 
> > > Below is an extract of patch-2.6.22, showing that the lines 330 and 388 have
> > > been removed from 'drivers/net/wireless/zd1201.c'. I put those two lines back,
> > > which made things work as expected again; however, that is only meant as a
> > > hint, since i don't know why they were taken out or what other implications my
> > > change might have.
> > > 
> > > patch-2.6.22, lines 586509-586528:
> > > {{{
> > > diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
> > > index 6cb66a3..935b144 100644
> > > --- a/drivers/net/wireless/zd1201.c
> > > +++ b/drivers/net/wireless/zd1201.c
> > > @@ -327,7 +327,6 @@ static void zd1201_usbrx(struct urb *urb)
> > >                         memcpy(skb_put(skb, 6), &data[datalen-8], 6);
> > >                         memcpy(skb_put(skb, 2), &data[datalen-24], 2);
> > >                         memcpy(skb_put(skb, len), data, len);
> > > -                       skb->dev = zd->dev;
> > >                         skb->dev->last_rx = jiffies;
> > >                         skb->protocol = eth_type_trans(skb, zd->dev);
> > >                         zd->stats.rx_packets++;
> > > @@ -385,7 +384,6 @@ static void zd1201_usbrx(struct urb *urb)
> > >                         memcpy(skb_put(skb, 2), &data[6], 2);
> > >                         memcpy(skb_put(skb, len), data+8, len);
> > >                 }
> > > -               skb->dev = zd->dev;
> > >                 skb->dev->last_rx = jiffies;
> > >                 skb->protocol = eth_type_trans(skb, zd->dev);
> > >                 zd->stats.rx_packets++;
> > > }}}
> > > 
> > 
> > Arnaldo, we have a pretty solid report here that your
> > 4c13eb6657fe9ef7b4dc8f1a405c902e9e5234e0 made this driver go crash.
> 
> In 2.6.22 and later, eth_type_trans() sets skb->dev.  It looks like the
> lines tha tset last_rx in the patch above should be moved below the
> eth_type_trans() lines, otherwise they'll likely oops.
> 
> Something like this is probably in order?

I think so, its strange that this bisects to me, but Dan's change should
fix it.

- Arnaldo
