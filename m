From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] TX throttling bug-fixing patch of AX88179_178A
Date: Mon, 22 Jul 2013 23:10:27 -0700
Message-ID: <1374559827.4990.143.camel@edumazet-glaptop>
References: <1374311809-4155-1-git-send-email-freddy@asix.com.tw>
	 <1374512879.4990.19.camel@edumazet-glaptop>
	 <CANEJEGvPc56ePP=_bxfA4PZfsM3vw=MsRjbWwrFBC3eP-GtzZg@mail.gmail.com>
	 <1374518312.1635.29.camel@bwh-desktop.uk.level5networks.com>
	 <1374518841.4990.26.camel@edumazet-glaptop>
	 <1374522471.1635.48.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ASIX Louis =?UTF-8?Q?=5B=E8=98=87=E5=A8=81=E9=99=B8=5D?=
	<louis-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>, Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1374522471.1635.48.camel-/LGg1Z1CJKQ+9kgCwbf1HqK4ta4zdZpAajtMo4Cw6ucAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-07-22 at 20:47 +0100, Ben Hutchings wrote:
> On Mon, 2013-07-22 at 11:47 -0700, Eric Dumazet wrote:
> > On Mon, 2013-07-22 at 19:38 +0100, Ben Hutchings wrote:
> > > On Mon, 2013-07-22 at 11:29 -0700, Grant Grundler wrote:
> > > > On Mon, Jul 22, 2013 at 10:07 AM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > > > ...
> > > > > I guess that if a driver does not advertise NETIF_F_SG, this
> > > > > skb_linearize() call is not needed : All frames reaching your xmit
> > > > > function should already be linear
> > > > 
> > > > As Ben Hutchings pointed out, hw_features is still setting this...but
> > > > I'm not sure how that matters.
> > > > 
> > > > ax88179_set_features() doesn't allow setting SG or TSO features.  But
> > > > I expect it would be "not too difficult" to add such that ethtool
> > > > could set those features after boot.
> > > [...]
> > > 
> > > It already can.  That's what putting feature flags in hw_features does.
> > 
> > My original concern, that inspired this patch, was to remove SG support,
> > as this driver does not have SG support at all.
> > 
> > Linearize a full TSO packet needs order-5 allocations, thats likely to
> > fail and lead to very slow TCP performance, because it will only rely on
> > retransmits.
> 
> The driver could set gso_max_size to reduce that problem.  But I rather
> doubt that TSO followed by skb_linearize() significantly improves
> throughput or CPU-efficiency.  (If the device has a 1G link but is
> connected to the host through a USB 2.0 port, then USB is the bottleneck
> and TSO could improve throughput a few percent.  But that's a silly
> configuration.)
> 
> The real solution would be for someone to add SG support to the usbnet
> core.  Trying to support 1GbE with only linear skbs is not a great
> idea... and it can only be a matter of time before there is USB ultra
> speed (or whatever comes after 'super') with 10GbE devices...
> 

This sounds a good idea.

Is anybody working on adding SG to usbnet ?



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
