From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 1/2] ipvlan: don't loose broadcast MAC when setting MAC filters
Date: Mon, 30 Mar 2015 14:11:37 -0700
Message-ID: <CAF2d9jipTV4f4NOgGRY-kGOyRBe5HAH6T-mj4G9FYnc7oyc+NA@mail.gmail.com>
References: <1427409698.18540.11.camel@redhat.com> <CAF2d9jjF20puZvoAD502rAzYAaraRtpZZRK-=vcZGu-Uv4wZMA@mail.gmail.com>
 <1427749308.1913.28.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>, jbenc@redhat.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:33066 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661AbbC3VL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 17:11:58 -0400
Received: by obvd1 with SMTP id d1so75291124obv.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 14:11:57 -0700 (PDT)
In-Reply-To: <1427749308.1913.28.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 2:01 PM, Dan Williams <dcbw@redhat.com> wrote:
> On Mon, 2015-03-30 at 13:28 -0700, Mahesh Bandewar wrote:
>> On Thu, Mar 26, 2015 at 3:41 PM, Dan Williams <dcbw@redhat.com> wrote:
>> > The broadcast MAC is supposed to be allowed whenever the device
>> > has an IPv4 address, otherwise ARP requests get dropped on the
>> > floor.  If ndo_set_rx_mode (and thus
>> > ipvlan_set_multicast_mac_filter()) gets called after the address
>> > was added, it blows away the broadcast MAC address in
>> > mac_filters that was added at IPv4 address addition.  Fix that.
>> >
>> > Signed-off-by: Dan Williams <dcbw@redhat.com>
>> Acked-by: Mahesh Bandewar <maheshb@google.com>
>
> I'm actually going to send another patch that supercedes this one and
> handles the DHCP issue in a slightly different way.
>
Sure, I'll take a look at that but irrespective of how DHCP is
handled, this patch fixes the problem that you have described since
ndo_set_rxmode will wipe the broadcast bit if set and will end up
breaking the IPv4. So I feel that this is still required in some-form.

> Dan
>
>> > ---
>> >  drivers/net/ipvlan/ipvlan_main.c | 3 +++
>> >  1 file changed, 3 insertions(+)
>> >
>> > diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
>> > index 4f4099d..d34f580 100644
>> > --- a/drivers/net/ipvlan/ipvlan_main.c
>> > +++ b/drivers/net/ipvlan/ipvlan_main.c
>> > @@ -241,6 +241,9 @@ static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
>> >
>> >                 bitmap_copy(ipvlan->mac_filters, mc_filters,
>> >                             IPVLAN_MAC_FILTER_SIZE);
>> > +
>> > +               if (ipvlan->ipv4cnt)
>> > +                       ipvlan_set_broadcast_mac_filter(ipvlan, true);
>> >         }
>> >         dev_uc_sync(ipvlan->phy_dev, dev);
>> >         dev_mc_sync(ipvlan->phy_dev, dev);
>> > --
>> > 2.1.0
>> >
>> >
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
