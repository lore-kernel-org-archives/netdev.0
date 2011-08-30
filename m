From: Dave Taht <dave.taht@gmail.com>
Subject: Re: BQL crap and wireless
Date: Mon, 29 Aug 2011 17:24:56 -0700
Message-ID: <CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
	<CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Matt Smith <smithm@qca.qualcomm.com>,
	Kevin Hayes <hayes@qca.qualcomm.com>,
	Derek Smithies <derek@indranet.co.nz>, netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42130 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741Ab1H3AY5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 20:24:57 -0400
In-Reply-To: <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 29, 2011 at 2:02 PM, Luis R. Rodriguez <mcgrof@gmail.com> w=
rote:
> On Fri, Aug 26, 2011 at 4:27 PM, Luis R. Rodriguez <mcgrof@gmail.com>=
 wrote:

> Let me elaborate on 802.11 and bufferbloat as so far I see only crap
> documentation on this and also random crap adhoc patches.

I agree that the research into bufferbloat has been an evolving topic, =
and
the existing documentation and solutions throughout the web is inaccura=
te
 or just plan wrong in many respects. While I've been accumulating bett=
er
and more interesting results as research continues, we're not there yet=
=2E..

> Given that I
> see effort on netdev to try to help with latency issues its important
> for netdev developers to be aware of what issues we do face today and
> what stuff is being mucked with.

Hear, Hear!

> As far as I see it I break down the issues into two categories:
>
> =A0* 1. High latencies on ping
> =A0* 2. Constant small drops in throughput

I'll take on 2, in a separate email.

>
> =A01. High latencies on ping
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

=46or starters, no, "high - and wildly varying - latencies on all sorts
of packets".

Ping is merely a diagnostic tool in this case.

If you would like several gb of packet captures of all sorts of streams
from various places and circumstances, ask. JG published a long
series about 7 months back, more are coming.

Regrettably most of the most recent traces come from irreproducible
circumstances, a flaw we are trying to fix after 'CeroWrt' is finished.

> It seems the bufferbloat folks are blaming the high latencies on our
> obsession on modern hardware to create huge queues and also with
> software retries. They assert that reducing the queue length
> (ATH_MAX_QDEPTH on ath9k) and software retries (ATH_MAX_SW_RETRIES on
> ath9k) helps with latencies. They have at least empirically tested
> this with ath9k with
> a simple patch:
>
> https://www.bufferbloat.net/attachments/43/580-ath9k_lowlatency.patch
>
> The obvious issue with this approach is it assumes STA mode of
> operation, with an AP you do not want to reduce the queue size like
> that. In fact because of the dynamic nature of 802.11 and the

If there is any one assumption about the bufferbloat issue that people
keep assuming we have, it's this one.

In article after article, in blog post after blog post, people keep
'fixing' bufferbloat by setting their queues to very low values,
and almost miraculously start seeing their  QoS start working
(which it does), and then they gleefully publish their results
 as recommendations, and then someone from the bufferbloat
effort has to go and comment on that piece, whenever we
notice, to straighten them out.

In no presentation, no documentation, anywhere I know of,
have we expressed  that queuing as it works today
is the right thing.

More recently, JG got fed up and wrote these...

http://gettys.wordpress.com/2011/07/06/rant-warning-there-is-no-single-=
right-answer-for-buffering-ever/

http://gettys.wordpress.com/2011/07/09/rant-warning-there-is-no-single-=
right-answer-for-buffering-ever-part-2/

There has been no time, since the inception of the bufferbloat
concept, have we had a fixed buffer size in any layer of the
stack as even a potential solution.

And you just did applied that preconception to us again.

My take on matters is that *unmanaged* buffer sizes > 1 is a
problem. Others set the number higher.

Of late, given what tools we have, we HAVE been trying to establish
what *good baseline* queue sizes (txqueues, driver queues, etc)
actually are for wireless under ANY circumstance that was
duplicate-able.

=46or the drivers JG was using last year, that answer was: 0.

Actually, less than 0  would have been good, but that
would have involved having tachyon emitters in the
architecture.

=46or the work that felix and andrew recently performed on the ath9k,
it looks to be about 37 for STA mode, but further testing is required
and is taking place... as well as instrumentation of the tcp stack, cha=
nges
to the system clock interrupt,  and a horde of other things.

As for AP performance... don't know. Am testing, capturing streams,
testing contention, building up labs, and creating a distro to deploy
to the field to test everything with.


> different modes of operation it is a hard question to solve on what
> queue size you should have. The BQL effort seems to try to unify a
> solution but obviously did not consider 802.11's complexities.

I only noticed the presentation and thread a few days ago. I do happen
to like byte, rather than packet limits, as a start towards sanity, but
framing overhead is still a problem, and an effective API and
set of servos more so.

> 802.11
> makes this very complicated given the PtP and PtMP support we have an=
d
> random number of possible peers.
>
> Then -- we have Aggregation. At least AMPDU Aggregation seems to
> empirically deteriorate latency and bufferbloat guys seem to hate it.

I think aggregation is awesome, actually. I've said so on multiple occa=
sions.

After reading the early work done on it, back in the early 2000s, I tho=
ught it
could not be made to work, at all. I was wrong.

The problems I have with aggregation as seemingly commenly
implemented today are:

0) Attempts to make the media look 100% perfect
1) Head of line blocking
2) Assumption that all packets are equal.
3) Co-existence with previous forms of 802.11 is difficult
4) Horrible behavior with every AQM algorithm, particularly with fair q=
ueuing

> Of course their statements are baseless and they are ignoring a lot o=
f
> effort that went into this. Their current efforts have been to reduce
> segment size of a aggregates and this seems to help but the same

I note that some of the ongoing suggestions actually will make it stati=
stically
more likely that stuff emerging from higher levels of the stack will be=
 even
more aggregate-able than it is currently.

Also, it would be good to have some statistics as to how good aggregati=
on
is currently, actually working under normal multiuser workloads.
A suggestion of felix's was to make that available via netlink broadcas=
t.

> problem looms over this resolution -- the optimal aggregation segment
> size should be dynamic and my instincts tell me we likely need to als=
o
> rely on a minstrel-like based algorithm for finding the optimal lengt=
h.

We agree very much it should be dynamic.



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://the-edge.blogspot.com
