From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 1/8] qed: LL2 to use packed information for tx
Date: Fri, 9 Jun 2017 07:51:33 +0000
Message-ID: <BLUPR0701MB2004CA6F1F262EC4E815E6B58DCE0@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170608161323.7597-1-Yuval.Mintz@cavium.com>
        <20170608161323.7597-2-Yuval.Mintz@cavium.com>
 <20170608.192358.1444190196602150329.davem@davemloft.net>
 <063D6719AE5E284EB5DD2968C1650D6DD001B851@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "Kalderon, Michal" <Michal.Kalderon@cavium.com>
To: David Laight <David.Laight@ACULAB.COM>,
        'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0064.outbound.protection.outlook.com ([104.47.33.64]:45568
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751505AbdFIHvh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 03:51:37 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD001B851@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Laight [mailto:David.Laight@ACULAB.COM]
> Sent: Friday, June 09, 2017 10:28 AM
> To: 'David Miller' <davem@davemloft.net>; Mintz, Yuval
> <Yuval.Mintz@cavium.com>
> Cc: netdev@vger.kernel.org; linux-rdma@vger.kernel.org; Kalderon, Michal
> <Michal.Kalderon@cavium.com>
> Subject: RE: [PATCH net-next 1/8] qed: LL2 to use packed information for =
tx
>=20
> From: David Miller
> > Sent: 09 June 2017 00:24
> >
> > From: Yuval Mintz <Yuval.Mintz@cavium.com>
> > Date: Thu, 8 Jun 2017 19:13:16 +0300
> >
> > > @@ -67,6 +79,21 @@ struct qed_ll2_stats {
> > >  	u64 sent_bcast_pkts;
> > >  };
> > >
> > > +struct qed_ll2_tx_pkt_info {
> > > +	u8 num_of_bds;
> > > +	u16 vlan;
> > > +	u8 bd_flags;
> > > +	u16 l4_hdr_offset_w;	/* from start of packet */
> > > +	enum qed_ll2_tx_dest tx_dest;
> > > +	enum qed_ll2_roce_flavor_type qed_roce_flavor;
> > > +	dma_addr_t first_frag;
> > > +	u16 first_frag_len;
> > > +	bool enable_ip_cksum;
> > > +	bool enable_l4_cksum;
> > > +	bool calc_ip_len;
> > > +	void *cookie;
> > > +};
> > > +
> >
> > This layout is extremely inefficient, with lots of padding in between
> > struct members.
> >
> > Group small u8 members and u16 members together so that they consume
> > full 32-bit areas so you can eliminate all of the padding.
>=20
> I'd also query the use of u16 sizes/lengths, any arithmetic on u16 (and u=
8)
> variables is likely to generate extra code (on non-x86).
> You are using 32 bits for the 'enum' - I bet the values fit in 8 bits, so=
 aren't
> really worried about size.
>=20
> If size did matter you can easily get the above down to 32 bytes.

You're right, and that's exactly the point -  since this is not data-path c=
ritical
I don't see why the size/efficiency should matter [greatly].
