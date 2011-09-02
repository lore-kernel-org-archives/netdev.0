From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: BQL crap and wireless
Date: Fri, 2 Sep 2011 14:59:53 -0700
Message-ID: <CAB=NE6V-GtHAiaqCqzgo5JSgYT55S2LARr+_NQv3D6WjgvqE7w@mail.gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
 <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
 <CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com>
 <4E5C3B47.1050809@freedesktop.org> <CA+mtBx-j_+mrNpntR7CfYOromDnM-ZGzvebpUCjC8Qf14X6u9g@mail.gmail.com>
 <CAJ-Vmonwur-SXddNwjPEidCMqes+PwbRWFBddfdwTp2jOMu64g@mail.gmail.com>
 <4E5CEC79.3090802@freedesktop.org> <9BB251C1-A211-486D-A717-59149AC3A709@gmail.com>
 <4E5E36EE.8080501@freedesktop.org> <CAB=NE6Wj4BxSjZmTOg9EFMcJ+H0RBZE4q8+6DB3x8qP=r42yNQ@mail.gmail.com>
 <4E5FA74D.5000705@freedesktop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Adrian Chadd <adrian-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>,
	Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Matt Smith <smithm-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Kevin Hayes <hayes-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Derek Smithies <derek-Rd3uoDiDeHXJKwlM9GxbOw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E5FA74D.5000705-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

BTW Jim, as you may have found out after sending this reply, vger
hates HTML e-mails so your e-mail only got to those on the CC list but
not to the list. I'm replying below, but since I'm now using ASCII
text the look of the e-mail will look like poo, I'll try to trim it
somehow as I did find valuable information you provided there. I also
make some suggestions below.

On Thu, Sep 1, 2011 at 8:39 AM, Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org> wrote:
> On 08/31/2011 04:50 PM, Luis R. Rodriguez wrote:
>
> On Wed, Aug 31, 2011 at 6:28 AM, Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org> wrot=
e:
>
> On 08/30/2011 05:47 PM, Andrew McGregor wrote:
>
> On 31/08/2011, at 1:58 AM, Jim Gettys wrote:
>
> On 08/29/2011 11:42 PM, Adrian Chadd wrote:
>
> On 30 August 2011 11:34, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>
> C(P) is going to be quite variable - a full frame retransmit of a 4ms
> long aggregate frame is SUM(exponential backoff, grab the air,
> preamble, header, 4ms, etc. for each pass.)
>
> It's not clear to me that doing heroic measures to compute the cost i=
s
> going to be worthwhile due to the rate at which the costs can change =
on
> wireless; just getting into the rough ballpark may be enough. But
> buffering algorithms and AQM algorithms are going to need an estimate=
 of
> the *time* it will take to transmit data, more than # of bytes or pac=
kets.
>
> That's not heroic measures; mac80211 needs all the code to calculate =
these
> times anyway, it's just a matter of collecting together some things w=
e
> already know and calling the right function.
>
>
> Fine; if it's easy, accurate is better (presuming the costs get
> recalculated when circumstances change). We also will need the amount=
 of
> data being transmitted; it is the rate of transmission (the rate at
> which the buffers are draining) that we'll likely need.
>
> Here's what I've gleaned from reading "RED in a different light", =C2=
=A0Van
> Jacobson's Mitre talk and several conversations with Kathleen Nichols
> and Van: AQM algorithms that can handle variable bandwidth environmen=
ts
> will need to be able to know the rate at which buffers empty. =C2=A0I=
t's the
> direction they are going with their experiments on a "RED light" algo=
rithm.
>
> The fundamental insight as to why classic RED can't work in the wirel=
ess
> environment is that the instantaneous queue length has little actual
> information in it.

> Classic RED is tuned using the queue length as its
> basic parameter. =C2=A0Their belief as to algorithms that will work i=
s that
> the need to keep track of the running queue length *minimum over time=
*;
> you want to keep the buffers small on a longer term basis (so they bo=
th
> can absorb transients, which is their reason for existence, while
> keeping the latency typically low).

More details explained by Jim:

> TCP will fill any buffer just before the bottleneck in a path.=C2=A0 =
And, of
> course, other traffic transients can help fill the buffers too.=C2=A0=
 This is a
> natural consequence of it trying to figure out how fast it can run.
>
> Remember, TCP's job is to figure out just how fast it can go, so in i=
ts
> congestion avoidance phase, it increases the rate at which it transmi=
ts
> slowly (typical congestion avoidance algorithms will add one packet/a=
ck to
> the bottleneck buffer).=C2=A0 This is why in my traces you can find
> at:
> http://gettys.wordpress.com/2010/12/06/whose-house-is-of-glasse-must-=
not-throw-stones-at-another/
> you see something that sort of looks like a TCP sawtooth, but not: wi=
th
> periodicity of order 10 seconds (given the amount of buffering in tha=
t
> modem).
>
> What's happening is that as the buffer fills, the acks come back slow=
er and
> slower

Wait, why is that though?

> (so the buffer fills somewhat more slowly) with time. But as they
> fill, not only do you get additional latency, but the buffers become =
less
> and less effective at doing what they are intended for: smoothing tra=
nsients
> of higher rate incoming packets.

Is this bufferbloat or TCP not taking into consideration possible
variations in latency?

> So I ended up with 1.2 seconds of latency on my cable modem.

Jeesh.

> Depending on
> how much buffering is in the device, you get different amounts of lat=
ency
> under load.=C2=A0 So at the provisioned bandwidth of those tests, my =
cable modem
> has at least 10x the "classic" BDP amount of buffering.

And for readers BDP is:

http://en.wikipedia.org/wiki/TCP_tuning#Bandwidth-delay_product_.28BDP.=
29

The max in-flight possible unacknowledged data in transit.

Just curious -- why would they have 10x the amount of BDP??

> Eventually, the bloated buffer does fill, (which might be a megabyte =
in
> size, btw, on some cable modems), and you get packet loss.

Why is that though?

> But well before this should have occurred, TCP Cubic has decided the =
path
> may have changed, and goes into a more aggressive search for a new op=
erating
> point (so you see something that starts like a TCP sawtooth, but then
> switches back to something that looks more like slow start). This cau=
ses a
> long period bursty oscillation; the bursts are when multiple packet d=
rops
> are occurring (because the TCP is hammering at the cable modem at way=
 too
> high a speed for a short period).

Got it.

> Buffer bloat has therefore managed to destroy congestion avoidance
> entirely.=C2=A0 Sigh...=C2=A0 It also does a number on slow start, as=
 the amount of
> buffering is way more than it should be and it takes several sets of =
packet
> loss before TCP even starts congestion avoidance.

So an observable trait is we likely can see some packet loss during
the shifts in throughput? Is that accurate?

=46or 802.11 this could be a lot of things -- some new noise,
interference, etc, but for Ethernet I'm curious what would cause this
assuming we ware blaming the fact that a lot of buffers are queued, is
the issue that the time it takes to flush out buffers surpasses some
timer on the OS to actually transmit the frames?

> On some home routers, the buffering is even more extreme; so whenever=
 your
> bottleneck is in your home router (easy to do in my house as I have c=
himneys
> and lots of walls) the buffers in the home router become the problem.
>
> So I caught my home router of that era (it was a DIR 825, IIRC) with =
8
> seconds of latency one evening.

Shit.

> =C2=A0The additional major challenge we
> face that core routers do not is the highly variable traffic of mixed
> mice and elephants. =C2=A0What actually works only time will tell.

Just FYI for 802.11 we have some effort to help us classify management
frames further into different access categories, typically we just
always use AC_VO to transmit management frames but the work undergoing
in 802.11ae Prioritization of Management frames allows us to assign
different ACs to different types of management frames, and the AP can
actually define these rules. People interested in this problem should
look at that and try out the defined default QoS management frame
profile and see if that helps. That is -- something like this might be
good for the bufferbloat experimental work -- but get it upstream,
don't fork ;)

> All this was well understood in the 1990's.=C2=A0 Most of us *thought=
* the
> problem was solved by AQM algorithms such as RED.=C2=A0 I was nodding=
ly aware of
> AQM in the 1990's as I was working on HTTP in the IETF in that era, a=
nd AQM
> and buffer management in core routers was a very hot topic then.
>
> But the buffer management problem wasn't actually solved, and that re=
sult
> never got properly published, for the reasons I went into in:
>
> http://gettys.wordpress.com/2010/12/17/red-in-a-different-light/
>
> The field has languished since, and the problems that variable bandwi=
dth
> present went unrecognised.

Then I stated:

> Thank you for elaborating on this, it helps to further dissect the
> issues. When mixing them together it makes the task harder to address=
=2E
> As for 802.11 we'd just need to worry about management frames. Dave
> and Andrew had also pointed out issues with multicast and the low
> rates used for them in comparison to unicast transmissions.

And you said:

> What matters for bufferbloat is how much payload gets moved per unit =
time:
> that is what is accumulating in the OS packet buffers.
>
>
> So in an environment in which the rate of transmission is highly
> variable,

I had interjected with:

> Not only that, remember we have different possible topologies
> depending on the type of 802.11 service used, IBSS, the typical AP-ST=
A
> environment, Mesh, P2P (AP-STA really), and now with 802.11ad we get
> PBSS. What counts here is we may have variable rate of transmission t=
o
> different possible peers, as such the queue length will depend on all
> of the expected transmissions.

and you had continued with:

> such as wireless, or even possibly modern broadband with
> PowerBoost, classic RED or similar algorithms that do not take the
> buffer drain rate cannot possibly hack it properly.

I had said:

> Understood, just curious if anyone has tried a Minstrel approach.
>
> Lets try to document all of this here:
>
> http://wireless.kernel.org/en/developers/bufferbloat

Then you ended with:

> Please do.=C2=A0 Or work on the material in the bufferbloat.net wiki.=
=C2=A0 I'm now
> too close to the problem to be good at explaining it any better than =
I try
> to here and in my other writings.=C2=A0 Thomas Jefferson writing is *=
hard*.
>
> Probably best is that generic descriptions go into the bufferbloat.ne=
t wiki,
> and linux specific stuff on kernel.org; but I don't honestly care all=
 that
> much where it is so long as it does get written down, along with the
> importance of Minstrel like algorithms in dealing with the variable
> bandwidth problem (which isn't in any of the material in my blog or
> bufferbloat.net, having not understood the problem there myself at al=
l
> before a month or two ago when Andrew McGregor explained to me in det=
ail
> what Minstrel is and does and why it needs to exist).

Sure, will work on this.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
