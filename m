From: Adrian Chadd <adrian-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>
Subject: Re: BQL crap and wireless
Date: Tue, 30 Aug 2011 11:42:32 +0800
Message-ID: <CAJ-Vmonwur-SXddNwjPEidCMqes+PwbRWFBddfdwTp2jOMu64g@mail.gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
	<CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
	<CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com>
	<4E5C3B47.1050809@freedesktop.org>
	<CA+mtBx-j_+mrNpntR7CfYOromDnM-ZGzvebpUCjC8Qf14X6u9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Matt Smith <smithm-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Kevin Hayes <hayes-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Derek Smithies <derek-Rd3uoDiDeHXJKwlM9GxbOw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+mtBx-j_+mrNpntR7CfYOromDnM-ZGzvebpUCjC8Qf14X6u9g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 30 August 2011 11:34, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> The generalization of BQL would be to set the queue limit in terms of
> a cost function implemented by the driver. =A0The cost function would
> most likely be an estimate of time to transmit a packet. =A0So C(P)
> could represent cost of a packet, sum(C(P) for P queued) is aggregate
> cost of queue packets, and queue limit is the maximum cost sum. =A0Fo=
r
> wired Ethernet, number of bytes in packet might be a reasonable
> function (although framing cost could be included, but I'm not sure
> that would make a material difference). =A0For wireless, maybe the
> function could be more complex possibly taking multicast, previous
> history of transmission times, or other arbitrary characteristics of
> the packet into account...
>
> I can post a new patch with this generalization if this is interestin=
g.

As I said before, I think this is the kind of thing the rate control
code needs to get its dirty hands into.

With 802.11 you have to care about the PHY side of things too, so your
cost suddenly would include the PER for combinations of {remote node,
antenna setup, TX rate, sub-frame length, aggregate length}, etc. Do
you choose that up front and then match a cost to it, or do you
involve the rate control code in deciding a "good enough" way of
handling what's on the queue by making rate decisions, then implement
random/weighted/etc drop of what's left? Do you do some weighted/etc
drop beforehand in the face of congestion, then pass what's left to
the rate control code, then discard the rest?

C(P) is going to be quite variable - a full frame retransmit of a 4ms
long aggregate frame is SUM(exponential backoff, grab the air,
preamble, header, 4ms, etc. for each pass.)


Adrian
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
