From: Avery Pennarun <apenwarr-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Cerowrt-devel] Fwd: Throughput regression with `tcp: refine TSO autosizing`
Date: Sun, 1 Feb 2015 23:04:41 -0500
Message-ID: <CAPp0ZBbKu-B3yPf0Et=XByJ1SrnxBgVbRXr9PBe0f6P08w87=Q@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
 <1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
 <54CB5D08.2070906@broadcom.com> <1422623975.21689.77.camel@edumazet-glaptop2.roam.corp.google.com>
 <54CB8B69.1070807@broadcom.com> <CAA93jw5fqhz0Hiw74L2GXgtZ9JsMg+NtYydKxKzGDrvQcZn4hA@mail.gmail.com>
 <CAA93jw7b0E9jjQYXrEPzjLLC9j8xNC0TFYXpWVtgFameJaNBdw@mail.gmail.com>
 <1422741065.199624134@apps.rackspace.com> <CAPp0ZBb2nkA6Y0s=W0kw=zvyn0wi0NMBRsBCw_xcD61ScOmgQg@mail.gmail.com>
 <CAA_e5Z46Bu+zZZFzf_ejzA35Gw3g1_OG85yv6yd7MpbwZcE-nw@mail.gmail.com>
 <CAA93jw7=oTex0Mp-0ThvuDRUnfR0N8tzdOQ8DD7QYWphp1b=4w@mail.gmail.com>
 <CAJq5cE3ETbpEtecFHmhgHQveNRUhVfrzjTOygHm-TRCTwHNyKA@mail.gmail.com>
 <1422801814.796219699@apps.rackspace.com> <CAA_e5Z5PfimZeC5cqSk_xFpKOBeZ74htLeEdwtKieAYWJaEX+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Reed <dpreed-pPKjjScK5eQ@public.gmane.org>,
	Jonathan Morton <chromatix99-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Matt Mathis <mattmathis-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org>, dstanley-lTB0Xd325TxqO0yjgLDq5wC/G2K4zDHf@public.gmane.org,
	Kathy Giori <kgiori-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Stig Thormodsrud <stig-NO1NBkfNQUg@public.gmane.org>,
	Derrick Pallas <pallas-sawT6J5uHbDQT0dZR+AlfA@public.gmane.org>,
	"cerowrt-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org"
	<cerowrt-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	Mahesh Paolini-Subramanya <mahesh-KjT+1lc9LyJnAhEpsgJxYdBPR1lH4CV8@public.gmane.org>,
	Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>,
	Jesper Dangaard Brouer <jbrouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAA_e5Z5PfimZeC5cqSk_xFpKOBeZ74htLeEdwtKieAYWJaEX+A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 1, 2015 at 6:34 PM, Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> I missed one item in my list of potential improvements: the most braindead
> thing 802.11 has to say about rates is that broadcast and multicast packets
> should be sent at 'the lowest basic rate in the current supported rate set',
> which is really wasteful.  There are a couple of ways of dealing with this:
> one, ignore the standard and pick the rate that is most likely to get the
> frame to as many neighbours as possible (by a scan of the Minstrel tables).
> Or two, fan it out as unicast, which might well take less airtime (due to
> aggregation) as well as being much more likely to be delivered, since you
> get ACKs and retries by doing that.

As far as I can see, the only sensible thing to do with
multicast/broadcast is some variation of the unicast fanout, unless
you've got a truly huge number of nodes.  I don't know of any
protocols (certainly not video streams) that actually work well with
the kind of packet loss you see at medium/long range with wifi if
retransmits aren't used.  I've heard that openwrt already has a patch
included that does this kind of fanout at the bridge layer.

I've also heard of a new "reliable multicast" in some newer 802.11
variant, which essentially sends out a single multicast packet and
expects an ACK from each intended recipient.  Other than adding
complexity, it seems like the best of both worlds.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
