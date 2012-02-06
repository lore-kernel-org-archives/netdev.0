From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next V2] gro: introduce gro_mac_header_len
Date: Mon, 6 Feb 2012 11:59:15 -0800
Message-ID: <CAG4TOxO2ngyfFAM4njQW6keujOkRH_SEY9+02BYKJNmzGv69kg@mail.gmail.com>
References: <20120206.141223.332863167187002998.davem@davemloft.net>
 <CAG4TOxNgJ3=AFuA==Km815YzW8eQ7nD_UAzkXLSXcAyaCAAvPg@mail.gmail.com>
 <20120206.143230.1415707004934341114.davem@davemloft.net> <20120206.145148.558736903670696169.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120206.145148.558736903670696169.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Actually there is a way to make this work.
>
> Define your ipoib_skb_cb something like:
>
> struct ipoib_skb_cb {
> =A0 =A0 =A0 =A0struct qdisc_skb_cb =A0 =A0 qdisc_cb;
>
> =A0 =A0 =A0 =A0... ipoib stuff goes here ...
> };
>
> That way you can use the SKB cb area for your ipoib info
> without interfering with the packet scheduler.

Not sure I see how this could work.  sch_generic.h has:

struct qdisc_skb_cb {
        unsigned int            pkt_len;
        long                    data[];
};

and ipoib has no way of knowing what the biggest
scheduler-specific use of data[] will be.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
