From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: BQL crap and wireless
Date: Mon, 29 Aug 2011 18:08:51 -0700
Message-ID: <CAA93jw4Dg--nz6F6fA0BACebXVdS9iY2As+__9ww1cu1Vy265Q@mail.gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
	<CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Matt Smith <smithm-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Kevin Hayes <hayes-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Derek Smithies <derek-Rd3uoDiDeHXJKwlM9GxbOw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> 2. Constant small drops in throughput
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D

Huge drops in throughput, actually.

> How to explain this? I have no clue. Two current theories:
>
> a. Dynamic Power save
> b. Offchannel operations on bgscans
> c. Bufferbloat: large hw queue size and sw retries
>
> One can rule out (a) and (b) by disabling Dynamic Power Save (iw dev
> wlan0 power_save off) and also bg scans. If its (c) then we can work
> our way up to proving a solution with the same fixes for the first
> latency issue. But there are more subtle issues here.

(in part, your) recent analysis of the periodicity of bandwidth drops
does point
strongly to points a and b being mis-implemented by many vendors and OS=
-makers,
and shows a clear path toward further testing by several labs.

> Bufferbloat
> folks talk about "ants" and "elephants". They call "Elephants" as
> frames that are just data, but "ants" are small frames that build mak=
e
> the networks work --

This is an over-simplification of a complex issue, and wrong.

Elephants are very large *streams* of tcp data, the kind you get after
a few seconds of operation, and mice are short ones, the kind you
commonly get with non-pipelined http protocols and normal websites.

As noted elsewhere, with tons of reference material on google and cites=
eer,
"tcp mice and elephants" are a well researched and understood topic -
or at least were, back when network research still happened, which
was prior to the explosion and predominance of wireless.

The need for AQMs such as RED, Blue, etc, to manage elephants was
well demonstrated back in  the early 90s. Being able to shoot/slow down
the elephants on a sane basis is also required to have sane shared
network behavior.

There has been a huge shift in TCP flows with first the advent of the
web for all things, and more recently, back again, with the rise of vid=
eo.

> so consider 802.11 management frames, and TCP
> ACKs, and so forth.

Um, actually, if TCP acks are 'ANT's, it's news to me, and I co-coined =
the term.

There is one special case, commonly implemented in cable modems, of
Syn and Syn/Ack optimization, that might pay off to some extent in wire=
less.

Upstream ACK prioritization does seem to help when it comes to
managing interactive
flows on asymmetric (e.g. home) networks as (for example) demonstrated =
by
wondershaper and other QoS mechanism.

But anything involving TCP fits into the well defined mice and
elephant categories
already, not ANTs.

I'm told that most management frames are in a separately managed queue =
already.

> They argue we should prioritize these more and
> ensure we use whatever techniques we can to ensure we reduce latency
> for them.

ARP, DHCP, ND, RA, and various forms of ipv6's ping based protocols,
most routing protocols
in many aspects, numerous other non-tcp protocols, all count as ANTs.

> At least on ath9k we only aggregate data frames, but that
> doesn't mean we are not aggregating other "ant" frames.

The approach that we are experimenting with now, is putting
ANT-like packets into the VO and VI queues as appropriate and out
of the BE or BK queues.

Too early to publish preliminary results, but I am encouraged by what
I've seen so far.

It's interesting to note that a lot of web traffic is actually marked
as bulk traffic (tos of bulk)
which ends up in the wireless BK queue, rather than BE.




--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://the-edge.blogspot.com
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
