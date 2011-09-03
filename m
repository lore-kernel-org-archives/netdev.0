From: Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>
Subject: Re: BQL crap and wireless
Date: Fri, 02 Sep 2011 23:01:03 -0400
Message-ID: <4E61986F.8000507@freedesktop.org>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com> <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com> <CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com> <4E5C3B47.1050809@freedesktop.org> <CA+mtBx-j_+mrNpntR7CfYOromDnM-ZGzvebpUCjC8Qf14X6u9g@mail.gmail.com> <CAJ-Vmonwur-SXddNwjPEidCMqes+PwbRWFBddfdwTp2jOMu64g@mail.gmail.com> <4E5CEC79.3090802@freedesktop.org> <9BB251C1-A211-486D-A717-59149AC3A709@gmail.com> <4E5E36EE.8080501@freedesktop.org> <CAB=NE6Wj4BxSjZmTOg9EFMcJ+H0RBZE4q8+6DB3x8qP=r42yNQ@mail.gmail.com> <4E5FA74D.5000705@freedesktop.org> <CAB=NE6V-GtHAiaqCqzgo5JSgYT55S2LARr+_NQv3D6WjgvqE7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Adrian Chadd <adrian-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>,
	Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Matt Smith <smithm-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Kevin Hayes <hayes-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Derek Smithies <derek-Rd3uoDiDeHXJKwlM9GxbOw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAB=NE6V-GtHAiaqCqzgo5JSgYT55S2LARr+_NQv3D6WjgvqE7w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/02/2011 05:59 PM, Luis R. Rodriguez wrote:
> BTW Jim, as you may have found out after sending this reply, vger
> hates HTML e-mails so your e-mail only got to those on the CC list but
> not to the list. I'm replying below, but since I'm now using ASCII
> text the look of the e-mail will look like poo, I'll try to trim it
> somehow as I did find valuable information you provided there. I also
> make some suggestions below.

Thunderbird is giving me fits in this department.  Fixed now.  My
apologies to everyone who abhors HTML mail.

> 
> On Thu, Sep 1, 2011 at 8:39 AM, Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org> wrote:
>> On 08/31/2011 04:50 PM, Luis R. Rodriguez wrote:
>>
>> On Wed, Aug 31, 2011 at 6:28 AM, Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org> wrote:
>>
>> On 08/30/2011 05:47 PM, Andrew McGregor wrote:
>>
>> On 31/08/2011, at 1:58 AM, Jim Gettys wrote:
>>
>> On 08/29/2011 11:42 PM, Adrian Chadd wrote:
>>
>> On 30 August 2011 11:34, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>>
>> C(P) is going to be quite variable - a full frame retransmit of a 4ms
>> long aggregate frame is SUM(exponential backoff, grab the air,
>> preamble, header, 4ms, etc. for each pass.)
>>
>> It's not clear to me that doing heroic measures to compute the cost is
>> going to be worthwhile due to the rate at which the costs can change on
>> wireless; just getting into the rough ballpark may be enough. But
>> buffering algorithms and AQM algorithms are going to need an estimate of
>> the *time* it will take to transmit data, more than # of bytes or packets.
>>
>> That's not heroic measures; mac80211 needs all the code to calculate these
>> times anyway, it's just a matter of collecting together some things we
>> already know and calling the right function.
>>
>>
>> Fine; if it's easy, accurate is better (presuming the costs get
>> recalculated when circumstances change). We also will need the amount of
>> data being transmitted; it is the rate of transmission (the rate at
>> which the buffers are draining) that we'll likely need.
>>
>> Here's what I've gleaned from reading "RED in a different light",  Van
>> Jacobson's Mitre talk and several conversations with Kathleen Nichols
>> and Van: AQM algorithms that can handle variable bandwidth environments
>> will need to be able to know the rate at which buffers empty.  It's the
>> direction they are going with their experiments on a "RED light" algorithm.
>>
>> The fundamental insight as to why classic RED can't work in the wireless
>> environment is that the instantaneous queue length has little actual
>> information in it.
> 
>> Classic RED is tuned using the queue length as its
>> basic parameter.  Their belief as to algorithms that will work is that
>> the need to keep track of the running queue length *minimum over time*;
>> you want to keep the buffers small on a longer term basis (so they both
>> can absorb transients, which is their reason for existence, while
>> keeping the latency typically low).
> 
> More details explained by Jim:
> 
>> TCP will fill any buffer just before the bottleneck in a path.  And, of
>> course, other traffic transients can help fill the buffers too.  This is a
>> natural consequence of it trying to figure out how fast it can run.
>>
>> Remember, TCP's job is to figure out just how fast it can go, so in its
>> congestion avoidance phase, it increases the rate at which it transmits
>> slowly (typical congestion avoidance algorithms will add one packet/ack to
>> the bottleneck buffer).  This is why in my traces you can find
>> at:
>> http://gettys.wordpress.com/2010/12/06/whose-house-is-of-glasse-must-not-throw-stones-at-another/
>> you see something that sort of looks like a TCP sawtooth, but not: with
>> periodicity of order 10 seconds (given the amount of buffering in that
>> modem).
>>
>> What's happening is that as the buffer fills, the acks come back slower and
>> slower
> 
> Wait, why is that though?

Because the data packets are more and more delayed through the link as
the buffer fills, delaying their arrival and therefore the acks.

Saturating one direction kills performance in the other direction; in
that case, your poor acks are stuck behind data packets.  Some cable
modems do prioritise acks above bulk data, but that's just about all the
classification they currently do.  Most broadband has a single queue.

So it takes time for TCP to fill the buffers; not so long in slow start,
but in the congestion avoidance phase, it becomes seconds to refill the
buffer over even short paths like the 10ms path I was testing on.

> 
>> (so the buffer fills somewhat more slowly) with time. But as they
>> fill, not only do you get additional latency, but the buffers become less
>> and less effective at doing what they are intended for: smoothing transients
>> of higher rate incoming packets.
> 
> Is this bufferbloat or TCP not taking into consideration possible
> variations in latency?
> 
>> So I ended up with 1.2 seconds of latency on my cable modem.
> 
> Jeesh.

Heh.  Look at the netalyzr scatter plots in my blog posting.  Lots of
the broadband edge is at multiple seconds. 1.2 seconds isn't really bad
as it goes (even though it's already so painful as to make web surfing
downright slow). It's really, really scarily bad.

Dave Clark at MIT first realised some hardware was overbuffered about 7
years ago when he found 6 second latencies on the DSLAM he owns.

He used this as a DOS attack against his son's excessive World of
Warcraft playing :-).  But until last summer, we didn't have the
netalyzer or mlabs data showing just how horribly common the bufferbloat
problem is in broadband.  The FCC data that just came out shows the
problem too...

On cable, the last I heard no one had managed to find a cable modem made
in the last 8 or more years that was "correctly buffered" according to
the "canonical" BDP rule of thumb (which isn't really actually very
useful, as my blog rants point out).

> 
>> Depending on
>> how much buffering is in the device, you get different amounts of latency
>> under load.  So at the provisioned bandwidth of those tests, my cable modem
>> has at least 10x the "classic" BDP amount of buffering.
> 
> And for readers BDP is:
> 
> http://en.wikipedia.org/wiki/TCP_tuning#Bandwidth-delay_product_.28BDP.29
> 
> The max in-flight possible unacknowledged data in transit.
> 
> Just curious -- why would they have 10x the amount of BDP??

Heh.  The possible reasons are large: Because the memory was there?
Becasue the lessons of the 1990's congestion had been forgotten or never
learned? Because everyone thinks they can only focus on their little
engineering problem, without having to think about what happens as part
of the entire end-to end system? Because almost no engineer tests
latency under load routinely (except crazies like me who are supposed to
be working on teleconferencing and know slightly too much)? Because
Speedtest.net and pingtest.net don't run the tests at the same time?
Because a short simple test doesn't fill the buffer?  Because most
people have been using Windows XP for their testing, and without TCP
window scaling, they don't have more than 64K bytes in-flight so one TCP
won't fill the buffers and they don't see the extreme behaviour that can
hurt them (except when their kids leave bittorrent running)? Because if
a manufacturer has a firmware bug, and they can paper over it by using
more buffering, and the buffer costs them zero and they want to ship
their broken firmware with the bug, what do you think companies do?

If you'd like some more why's, I can probably generate them; I spent
months last fall figuring out how we got in this mess.

Seriously, memory has gotten cheap.  So sometimes the memory is
literally just along for the ride, and the engineers don't even think
about it.

You can't get small enough chips any more on the low end cheap box.  You
deliberately have to *not* use memory you have.

And each generation of hardware has a higher bandwidth (to use the very
good ethernet history, we went from 3, to 10 to 100, to 1gig and now 10
gigE).

The amount of buffering you actually need to keep TCP running flat out
(for a single flow) is in fact one BDP (presuming multiple flows do not
synchronise); it's a worst case.  Recent research has pretty clearly
shown that in high speed core routers, radically less buffering is
actually needed.  But home routers do see the *worst case*, like my
simple file copy test that core routers never see.

So we've all be tuning for the highest bandwidth the hardware can ever
operate at, ignoring the fact that it is usually operating at a much
lower bandwidth.

In the DOCSIS example, the amount of buffering I have in my modem may in
fact be only 2-3 times too much if it is operating at 100MBPS.

But then people plug in that modem and are provisioned to run at
10-20Mbps for most tiers of service.

So with a fixed single buffer size, it's N times too big.  It can easily
be a factor of 10 too big, even if the modem has been "correctly" sized
at its highest possible operating bandwidth (presuming CONUS delay of
around 100ms).

The DOCSIS change is the sane mitigation until we have a working AQM
(Powerboost on cable means it too is variable bandwidth, on an instant
by instant basis): that is a change to the management MIB for cable
modems so the ISP can set the buffer size the modem is allowed to use;
so at least they'll be able to tell the modem to use buffers that are
sized proportional to the maximum rate the data can flow through the
cable modem given what the customer pays for.  This means that my ISP
could tell my cable modem at 10Mbps service to use 1/10 the buffering it
might at 100Mbps.

We should do a similar simple mitigation on ethernet at 100 and 10 Mbps
and cut down the rings and transmit queue proportionately as a first
step on ethernet.  Wireless is harder, though some mitigation can be
done when we know what we're doing (and don't just blindly have our
knobs set as though this were ethernet).

But real solutions will require AQM....

> 
>> Eventually, the bloated buffer does fill, (which might be a megabyte in
>> size, btw, on some cable modems), and you get packet loss.
> 
> Why is that though?
> 

The packets have no place to go: you are putting them in faster than
they can go out, so once the buffer is completely fill, you've got a
full bag of potatoes.  Depending on the code there, it may tail drop, or
sometimes you might even see some hardware that is completely braindead
and drop a pile at once.

>> But well before this should have occurred, TCP Cubic has decided the path
>> may have changed, and goes into a more aggressive search for a new operating
>> point (so you see something that starts like a TCP sawtooth, but then
>> switches back to something that looks more like slow start). This causes a
>> long period bursty oscillation; the bursts are when multiple packet drops
>> are occurring (because the TCP is hammering at the cable modem at way too
>> high a speed for a short period).
> 
> Got it.
> 
>> Buffer bloat has therefore managed to destroy congestion avoidance
>> entirely.  Sigh...  It also does a number on slow start, as the amount of
>> buffering is way more than it should be and it takes several sets of packet
>> loss before TCP even starts congestion avoidance.
> 
> So an observable trait is we likely can see some packet loss during
> the shifts in throughput? Is that accurate?

The easiest observed trait (if Linux is on both end, in which case the
TCP timestamp option will be on) is to look at the timestamps in the
packets.  Without knowing it, Van told me I had wonderful proof in my
packet captures right there.

Pragmatically, I did most of my work with ping, traceroute and
scp/netperf: (not even knowing of mtr or pingplotter on windows).  If
you see a link in a path you've saturated (in my case, by scp or
netperf), and the latency is unexpectedly high and varying, you've
probably got bufferbloat.

But bufferbloat certainly causes some excess packet loss, and bursty
behaviour as poor TCP becomes terminally confused.  It's causing DNS
lookup failures in my traces, when TCP really momentarily hammers the
cable modem.  Really quite remarkable stuff.

I'm not a TCP expert (IANATE); I knew just enough to grab the packet
captures, and since I had to stare at tcptrace results working on HTTP
in the 1990's, what I saw looked broken enough to me I called in the
really heavy guns go go over my traces (e.g. Dave Clark, Dave Reed, Greg
Chesson, Van Jacobson, and others).  I'm a complex systems guy.

Once aware of the problem (and knowing 3G had the problem from Dave
Reed's report the year before), and seeing my home router doing strange
things, I kept digging, looking for buffers.  Vint Cerf urged I just
start blogging about it to alert people late last year rather than doing
the formal publication thing. I just finally finished a first draft of a
formal paper for publication last month; it's probably another 1-2
months from completion.

The problem is, as soon as you get a bunch of TCP and other flows, it
gets really hard to figure out from simple symptoms or even from
tcptrace unless you're a pretty wizardly TCP guy.  I stumbled across the
"textbook" case first, and then could recognise symptoms I saw elsewhere
and dig further.  We need better tools badly.


> 
> For 802.11 this could be a lot of things -- some new noise,
> interference, etc, but for Ethernet I'm curious what would cause this
> assuming we ware blaming the fact that a lot of buffers are queued, is
> the issue that the time it takes to flush out buffers surpasses some
> timer on the OS to actually transmit the frames?

Cause which?

If you put data into a finite size buffer faster than it can come out,
something has to give once the buffer fills...  If you have infinite
memory, you can end up with infinite latency.

On wireless, you are more likely to get actual packet drop due to noise;
if you get 3 packet losses in a row, you force TCP to slow start and the
buffers may get a chance to drain a bit.  So ironically, the cleaner the
network, the worse things may behave. My cable turns out to be textbook
clean, so I got a really clean trace that could be understood.


> 
>> On some home routers, the buffering is even more extreme; so whenever your
>> bottleneck is in your home router (easy to do in my house as I have chimneys
>> and lots of walls) the buffers in the home router become the problem.
>>
>> So I caught my home router of that era (it was a DIR 825, IIRC) with 8
>> seconds of latency one evening.

I tried several other routers after that, with similar results.

> 
> Shit.
> 

I can make it much worse than 8 seconds; that's just what I documented
it doing one night in my house; you do the math:

We typically have about 1250 packets of buffering at the moment on most
Linux hardware: 1000 in the transmit queue, and 250 or so in the ring
buffers.  I'll ignore the socket buffers in this discussion.

That's almost 2 megabytes.

So if you happen to have a very slow link (my chimney), or are working
on a busy conference network where you "fair share" of the bandwidth
might be 1Mbps even much less, or a noisy network where you are having
lots of trouble getting data through it will take a long time.  At 1Mbps
 you can expect that to take about 16 seconds to drain those buffers.

Of course, you've usually gone home in disgust long before, presuming
that this is just "802.11 brain damage".  When in fact, it's often
bufferbloat, which has crept into nearly everything in the internet over
the last decade, including our operating systems and drivers. It may
actually be your laptop, or your broadband, or your isp...

And yes, there may also be 802.11 brain damage (e.g. how multicast
works), or driver bugs, or problems with aggregation, etc as well.

So far from every problem with horrid latency is bufferbloat...

3g has similar problems to 802.11, it turns out; but only in an
aggregate case due to details of how that works: buffers are being
filled by everyone's traffic.  30 seconds or more has been reported: the
most I've seen personally is 6 seconds.

The people time out before the packets get dropped; so packets get to
the destination, (and the network guys does not notice the packet drop
and aren't looking at the time the packets were in flight). So the user
times out, packets arrive to applications either thrown away or being
ignored the load drops, and you get horrific performance.


>>  The additional major challenge we
>> face that core routers do not is the highly variable traffic of mixed
>> mice and elephants.  What actually works only time will tell.
> 
> Just FYI for 802.11 we have some effort to help us classify management
> frames further into different access categories, typically we just
> always use AC_VO to transmit management frames but the work undergoing
> in 802.11ae Prioritization of Management frames allows us to assign
> different ACs to different types of management frames, and the AP can
> actually define these rules. People interested in this problem should
> look at that and try out the defined default QoS management frame
> profile and see if that helps. That is -- something like this might be
> good for the bufferbloat experimental work -- but get it upstream,
> don't fork ;)
> 

Yeah, and we should probably classify some other packets into other than
bulk data queues: e.g. dhcp, dns, nd, etc.  Dave calls these "Ants";
little packets that scurry around and do necessary things in the network.

>> All this was well understood in the 1990's.  Most of us *thought* the
>> problem was solved by AQM algorithms such as RED.  I was noddingly aware of
>> AQM in the 1990's as I was working on HTTP in the IETF in that era, and AQM
>> and buffer management in core routers was a very hot topic then.
>>
>> But the buffer management problem wasn't actually solved, and that result
>> never got properly published, for the reasons I went into in:
>>
>> http://gettys.wordpress.com/2010/12/17/red-in-a-different-light/
>>
>> The field has languished since, and the problems that variable bandwidth
>> present went unrecognised.
> 
> Then I stated:
> 
>> Thank you for elaborating on this, it helps to further dissect the
>> issues. When mixing them together it makes the task harder to address.
>> As for 802.11 we'd just need to worry about management frames. Dave
>> and Andrew had also pointed out issues with multicast and the low
>> rates used for them in comparison to unicast transmissions.
> 
> And you said:
> 
>> What matters for bufferbloat is how much payload gets moved per unit time:
>> that is what is accumulating in the OS packet buffers.
>>
>>
>> So in an environment in which the rate of transmission is highly
>> variable,
> 
> I had interjected with:
> 
>> Not only that, remember we have different possible topologies
>> depending on the type of 802.11 service used, IBSS, the typical AP-STA
>> environment, Mesh, P2P (AP-STA really), and now with 802.11ad we get
>> PBSS. What counts here is we may have variable rate of transmission to
>> different possible peers, as such the queue length will depend on all
>> of the expected transmissions.

Yes, and that is what AQM algorithms handle and why they are essential;
if too much starts to be queued for a given path, it's probability of
getting marked goes up, so the endpoints slow down from the marking
(packet drop or ECN, if it were deployed) signalling TCP to go more
slowly, despite the fact that it's sharing the queue with traffic that
is able to move many times faster to a different path.  So packets never
accumulate on one path to block other paths that happen to cross at a
particular buffer.

Classic RED works this way; it's just that it doesn't adjust its
behaviour according to the rate at which the buffer can empty; it's
tuned by the queue length, which isn't something that is really useful
when our queue length necessarily has to vary according to the
instantaneous bandwidth that is available.

I was startled when I realised we should even be running AQM in our
hosts; if you have multiple paths, you really need AQM algorithms to
keep the traffic from one path from doing bad things to other paths.
(think about sharing a queue between a local file server, and a high
bandwidth path with intercontinental delays...)
I'd always thought of AQM as something "internet routers have to do".


The first time I really saw a large 802.11 network working well under
load was at NANOG in June (500 or so attendees) and the IETF last
summer: it's using enterprise access points with minimal buffering,
hooked up to cisco routers that are running with RED enabled, and doing
diffserv labelling to get the right packets priority. When you have
enough aggregated traffic (and ensure that everyone has really good
signal strength), you can manage to sort of make RED work well enough.

But homes are much harder: no aggregation, highly variable application
load, and chimneys and multiple walls. (Hotels are somewhat similar).
There's no reason why we can't get Linux do as well as what I've seen
now at NANOG and the IETF (if we can find an AQM algorithm that works
given the different load and traffic mix).  We just don't have the
amount of traffic flow that a big conference does that *sort of* allows
RED to work in that environment in a small (e.g. home) environment.

Note that the June NANOG was the first time I had a laptop running eBDP,
which was keeping my laptop queues from killing me under load.  In the
upstream direction, you're *always* at a bottleneck link these days when
running on wireless. I could have done VOIP over that loaded conference
network, and had latencies in the 50ms range....

> 
> and you had continued with:
> 
>> such as wireless, or even possibly modern broadband with
>> PowerBoost, classic RED or similar algorithms that do not take the
>> buffer drain rate cannot possibly hack it properly.
> 
> I had said:
> 
>> Understood, just curious if anyone has tried a Minstrel approach.
>>
>> Lets try to document all of this here:
>>
>> http://wireless.kernel.org/en/developers/bufferbloat
> 
> Then you ended with:
> 
>> Please do.  Or work on the material in the bufferbloat.net wiki.  I'm now
>> too close to the problem to be good at explaining it any better than I try
>> to here and in my other writings.  Thomas Jefferson writing is *hard*.
>>
>> Probably best is that generic descriptions go into the bufferbloat.net wiki,
>> and linux specific stuff on kernel.org; but I don't honestly care all that
>> much where it is so long as it does get written down, along with the
>> importance of Minstrel like algorithms in dealing with the variable
>> bandwidth problem (which isn't in any of the material in my blog or
>> bufferbloat.net, having not understood the problem there myself at all
>> before a month or two ago when Andrew McGregor explained to me in detail
>> what Minstrel is and does and why it needs to exist).
> 
> Sure, will work on this.
> 

Greatly appreciated.  I think pretty few people understand anywhere just
how clever Minstrel is at figuring out how fast to try to transmit.
Now, if we can connect it to a AQM algorithm that works....  Kathleen
Nichols was much happier when I saw her at the last IETF than in June.
There is hope to figure out an AQM algorithm that "just works". But
until we've actually tested algorithms in real situations that actually
work....  And while a single algorithm to rule them all would be nice,
we just have to find one that works for the environments we face.
					- Jim


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
