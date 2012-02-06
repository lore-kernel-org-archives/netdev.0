From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next V2] gro: introduce gro_mac_header_len
Date: Mon, 6 Feb 2012 11:23:21 -0800
Message-ID: <CAG4TOxNgJ3=AFuA==Km815YzW8eQ7nD_UAzkXLSXcAyaCAAvPg@mail.gmail.com>
References: <1328546834.2220.79.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20120206.115859.1384761795375582044.davem@davemloft.net> <CAG4TOxOBCbEEOtP62ZM1R3-6umebdbJFkK0bnjphLCZOgHzt1g@mail.gmail.com>
 <20120206.141223.332863167187002998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120206.141223.332863167187002998.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 6, 2012 at 11:12 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wro=
te:
>> IMHO the problem is in the IPoIB RFC: (4391) which makes
>> a distinction between an "encapsulation header" and the "link
>> layer address". =A0The LL address is what we put into ARP and
>> ND packets, and so I think we are forced into exposing that
>> to the network stack as our hardware address.
>
> An address is not a hardware MAC header, we're only talking
> about the length of the latter.
>
> If the addressing is such that you need to put the GID
> into the ARP/NDISC packets, and that's different from what
> ends up in the final encapsulation header, I really don't
> see what the problem is specificially with respect to the
> MAC header size.

Dave, please look at my whole email.  The problem is that
the LL addr is not what we need to send packets but it's all
we get in our .hard_header method.  So for eg unicast ARP
packets without a dst we have nowhere to stash what we
actually will need in our xmit method.

(The same problem for unicast ARPs applies to multicast
sends too).

Does the netdev driver own skb->cb between hard_header
and start_xmit?  If so we could use that instead of stealing
some header space, and that would at least let us not lie
about hard_header_len.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
