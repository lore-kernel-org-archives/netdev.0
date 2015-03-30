From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/2] ipvlan: don't loose broadcast MAC when setting MAC
 filters
Date: Mon, 30 Mar 2015 16:01:48 -0500
Message-ID: <1427749308.1913.28.camel@redhat.com>
References: <1427409698.18540.11.camel@redhat.com>
	 <CAF2d9jjF20puZvoAD502rAzYAaraRtpZZRK-=vcZGu-Uv4wZMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>, jbenc@redhat.com
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45689 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752085AbbC3VBa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 17:01:30 -0400
In-Reply-To: <CAF2d9jjF20puZvoAD502rAzYAaraRtpZZRK-=vcZGu-Uv4wZMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-30 at 13:28 -0700, Mahesh Bandewar wrote:
> On Thu, Mar 26, 2015 at 3:41 PM, Dan Williams <dcbw@redhat.com> wrote:
> > The broadcast MAC is supposed to be allowed whenever the device
> > has an IPv4 address, otherwise ARP requests get dropped on the
> > floor.  If ndo_set_rx_mode (and thus
> > ipvlan_set_multicast_mac_filter()) gets called after the address
> > was added, it blows away the broadcast MAC address in
> > mac_filters that was added at IPv4 address addition.  Fix that.
> >
> > Signed-off-by: Dan Williams <dcbw@redhat.com>
> Acked-by: Mahesh Bandewar <maheshb@google.com>

I'm actually going to send another patch that supercedes this one and
handles the DHCP issue in a slightly different way.

Dan

> > ---
> >  drivers/net/ipvlan/ipvlan_main.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> > index 4f4099d..d34f580 100644
> > --- a/drivers/net/ipvlan/ipvlan_main.c
> > +++ b/drivers/net/ipvlan/ipvlan_main.c
> > @@ -241,6 +241,9 @@ static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
> >
> >                 bitmap_copy(ipvlan->mac_filters, mc_filters,
> >                             IPVLAN_MAC_FILTER_SIZE);
> > +
> > +               if (ipvlan->ipv4cnt)
> > +                       ipvlan_set_broadcast_mac_filter(ipvlan, true);
> >         }
> >         dev_uc_sync(ipvlan->phy_dev, dev);
> >         dev_mc_sync(ipvlan->phy_dev, dev);
> > --
> > 2.1.0
> >
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
