From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH] Net-ethtool : Allow ethtool to set interface in loopback mode.
Date: Tue, 30 Nov 2010 13:22:06 -0800
Message-ID: <AANLkTik=YkC6w3d2ViOqH5AYcxfRB6eKx3Mk_6=aKXGH@mail.gmail.com>
References: <AANLkTikVaVv4fkLom+NSQgOUzCd2i3mbHkBNQ6PD4d9Y@mail.gmail.com>
	<1291129305.21077.9.camel@bwh-desktop>
	<AANLkTikM4=yOu9L7h0FZUkmMNG-LVdGsdSLOLJmw2+UW@mail.gmail.com>
	<1291144507.21077.56.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	laurent chavey <chavey@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:30863 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066Ab0K3VWJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 16:22:09 -0500
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id oAULM8ie016266
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 13:22:08 -0800
Received: from bwz13 (bwz13.prod.google.com [10.188.26.13])
	by wpaz9.hot.corp.google.com with ESMTP id oAULM7of002665
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 13:22:07 -0800
Received: by bwz13 with SMTP id 13so5657973bwz.29
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 13:22:06 -0800 (PST)
In-Reply-To: <1291144507.21077.56.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 11:15 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Tue, 2010-11-30 at 11:05 -0800, Mahesh Bandewar wrote:
>> On Tue, Nov 30, 2010 at 7:01 AM, Ben Hutchings
>> <bhutchings@solarflare.com> wrote:
> [...]
>> > > diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> > > index 6628a50..7523d45 100644
>> > > --- a/include/linux/ethtool.h
>> > > +++ b/include/linux/ethtool.h
>> > > @@ -678,6 +678,8 @@ struct ethtool_ops {
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct ethtool_rxfh_indir *);
>> > > =A0 =A0 =A0 =A0 int =A0 =A0 (*set_rxfh_indir)(struct net_device =
*,
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 const struct ethtool_rxfh_indir *);
>> > > + =A0 =A0 =A0 int =A0 =A0 (*get_loopback)(struct net_device *, u=
32 *);
>> > > + =A0 =A0 =A0 int =A0 =A0 (*set_loopback)(struct net_device *, u=
32);
>> > > =A0};
>> > > =A0#endif /* __KERNEL__ */
>> > >
>> > > @@ -741,6 +743,8 @@ struct ethtool_ops {
>> > > =A0#define ETHTOOL_GSSET_INFO =A0 =A0 0x00000037 /* Get string s=
et info */
>> > > =A0#define ETHTOOL_GRXFHINDIR =A0 =A0 0x00000038 /* Get RX flow =
hash indir'n table */
>> > > =A0#define ETHTOOL_SRXFHINDIR =A0 =A0 0x00000039 /* Set RX flow =
hash indir'n table */
>> > > +#define ETHTOOL_SLOOPBACK =A0 =A0 =A00x0000003a /* Enable / Dis=
able Loopback */
>> > [...]
>> >
>> > Where should loopback be done, when enabled? =A0As near as possibl=
e to the
>> > host, so it only covers the DMA engines, or as far away as possibl=
e, so
>> > it covers most of the MAC/PHY hardware?
>> >
>> Putting it very close to the HW would stress the maximum soft path a=
nd
>> would make it
>> beneficial to more people / developers. I understand that capabiliti=
es
>> offered by different
>> NIC vendors vary so it's little difficult to draw the line as to whe=
re
>> it =A0should be done.
>
> Of course, that's why I suggest 'as near/far as possible' rather than
> trying to specify the exact point at which loopback would be enabled.
>
>> So
>> if the theme to "maximize the soft path" is maintained, we can leave
>> it to the individual
>> driver(s) to maximize the value in offering.
>
> I think this should be specified, otherwise measurements on different
> types of NIC will not be comparable. =A0The ethtool API suffers great=
ly
> from losse specification and resulting inconsistency between drivers.
> So please add the comment that loopback should be enabled as near to =
the
> host as possible.
>

This could be seen more as a stress test tool than a performance tool. =
Also
I think having this feature available for developers is more important =
than
the place it is done. But I see your point of having more
inconsistencies, so I will
add the comment as guidance for implementation.

--mahesh..
