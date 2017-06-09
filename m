From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH net-next 1/8] qed: LL2 to use packed information for tx
Date: Fri, 9 Jun 2017 08:23:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD001B8C2@AcuExch.aculab.com>
References: <20170608161323.7597-1-Yuval.Mintz@cavium.com>
        <20170608161323.7597-2-Yuval.Mintz@cavium.com>
 <20170608.192358.1444190196602150329.davem@davemloft.net>
 <063D6719AE5E284EB5DD2968C1650D6DD001B851@AcuExch.aculab.com>
 <BLUPR0701MB2004CA6F1F262EC4E815E6B58DCE0@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: "'Mintz, Yuval'" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        'David Miller' <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BLUPR0701MB2004CA6F1F262EC4E815E6B58DCE0-v5ruerSQ/oj1oiTf6dR/AE5OhdzP3rhOnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mintz, Yuval
> Sent: 09 June 2017 08:52
> > From: David Laight [mailto:David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org]
> > Sent: Friday, June 09, 2017 10:28 AM
> > To: 'David Miller' <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>; Mintz, Yuval
> > <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> > Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Kalderon, Michal
> > <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> > Subject: RE: [PATCH net-next 1/8] qed: LL2 to use packed information for tx
> >
> > From: David Miller
> > > Sent: 09 June 2017 00:24
> > >
> > > From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> > > Date: Thu, 8 Jun 2017 19:13:16 +0300
> > >
> > > > @@ -67,6 +79,21 @@ struct qed_ll2_stats {
> > > >  	u64 sent_bcast_pkts;
> > > >  };
> > > >
> > > > +struct qed_ll2_tx_pkt_info {
> > > > +	u8 num_of_bds;
> > > > +	u16 vlan;
> > > > +	u8 bd_flags;
> > > > +	u16 l4_hdr_offset_w;	/* from start of packet */
> > > > +	enum qed_ll2_tx_dest tx_dest;
> > > > +	enum qed_ll2_roce_flavor_type qed_roce_flavor;
> > > > +	dma_addr_t first_frag;
> > > > +	u16 first_frag_len;
> > > > +	bool enable_ip_cksum;
> > > > +	bool enable_l4_cksum;
> > > > +	bool calc_ip_len;
> > > > +	void *cookie;
> > > > +};
> > > > +
> > >
> > > This layout is extremely inefficient, with lots of padding in between
> > > struct members.
> > >
> > > Group small u8 members and u16 members together so that they consume
> > > full 32-bit areas so you can eliminate all of the padding.
> >
> > I'd also query the use of u16 sizes/lengths, any arithmetic on u16 (and u8)
> > variables is likely to generate extra code (on non-x86).
> > You are using 32 bits for the 'enum' - I bet the values fit in 8 bits, so aren't
> > really worried about size.
> >
> > If size did matter you can easily get the above down to 32 bytes.
> 
> You're right, and that's exactly the point -  since this is not data-path critical
> I don't see why the size/efficiency should matter [greatly].

It is just good practise so that it happens automatically when it does matter.
Just swapping 'vlan' and 'bd_flags' would make it look much better.

	David

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
