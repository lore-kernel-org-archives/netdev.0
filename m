From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/8] qed: LL2 to use packed information for tx
Date: Fri, 9 Jun 2017 07:28:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD001B851@AcuExch.aculab.com>
References: <20170608161323.7597-1-Yuval.Mintz@cavium.com>
        <20170608161323.7597-2-Yuval.Mintz@cavium.com>
 <20170608.192358.1444190196602150329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "Michal.Kalderon@cavium.com" <Michal.Kalderon@cavium.com>
To: 'David Miller' <davem@davemloft.net>,
        "Yuval.Mintz@cavium.com" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.195]:57258 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751547AbdFIH2P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 03:28:15 -0400
In-Reply-To: <20170608.192358.1444190196602150329.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> Sent: 09 June 2017 00:24
> 
> From: Yuval Mintz <Yuval.Mintz@cavium.com>
> Date: Thu, 8 Jun 2017 19:13:16 +0300
> 
> > @@ -67,6 +79,21 @@ struct qed_ll2_stats {
> >  	u64 sent_bcast_pkts;
> >  };
> >
> > +struct qed_ll2_tx_pkt_info {
> > +	u8 num_of_bds;
> > +	u16 vlan;
> > +	u8 bd_flags;
> > +	u16 l4_hdr_offset_w;	/* from start of packet */
> > +	enum qed_ll2_tx_dest tx_dest;
> > +	enum qed_ll2_roce_flavor_type qed_roce_flavor;
> > +	dma_addr_t first_frag;
> > +	u16 first_frag_len;
> > +	bool enable_ip_cksum;
> > +	bool enable_l4_cksum;
> > +	bool calc_ip_len;
> > +	void *cookie;
> > +};
> > +
> 
> This layout is extremely inefficient, with lots of padding in between
> struct members.
> 
> Group small u8 members and u16 members together so that they consume
> full 32-bit areas so you can eliminate all of the padding.

I'd also query the use of u16 sizes/lengths, any arithmetic on u16 (and u8)
variables is likely to generate extra code (on non-x86).
You are using 32 bits for the 'enum' - I bet the values fit in 8 bits,
so aren't really worried about size.

If size did matter you can easily get the above down to 32 bytes.

	David
