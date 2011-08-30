From: Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>
Subject: Re: BQL crap and wireless
Date: Mon, 29 Aug 2011 21:22:15 -0400
Message-ID: <4E5C3B47.1050809@freedesktop.org>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com> <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com> <CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Matt Smith <smithm-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Kevin Hayes <hayes-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Derek Smithies <derek-Rd3uoDiDeHXJKwlM9GxbOw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/29/2011 08:24 PM, Dave Taht wrote:
> On Mon, Aug 29, 2011 at 2:02 PM, Luis R. Rodriguez <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> On Fri, Aug 26, 2011 at 4:27 PM, Luis R. Rodriguez <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> Let me elaborate on 802.11 and bufferbloat as so far I see only crap
>> documentation on this and also random crap adhoc patches.
> I agree that the research into bufferbloat has been an evolving topic, and
> the existing documentation and solutions throughout the web is inaccurate
>  or just plan wrong in many respects. While I've been accumulating better
> and more interesting results as research continues, we're not there yet...
>
>> Given that I
>> see effort on netdev to try to help with latency issues its important
>> for netdev developers to be aware of what issues we do face today and
>> what stuff is being mucked with.
> Hear, Hear!
>
>> As far as I see it I break down the issues into two categories:
>>
>>  * 1. High latencies on ping
>>  * 2. Constant small drops in throughput
> I'll take on 2, in a separate email.
>
>>  1. High latencies on ping
>> ===================
> For starters, no, "high - and wildly varying - latencies on all sorts
> of packets".
>
> Ping is merely a diagnostic tool in this case.
>
> If you would like several gb of packet captures of all sorts of streams
> from various places and circumstances, ask. JG published a long
> series about 7 months back, more are coming.
>
> Regrettably most of the most recent traces come from irreproducible
> circumstances, a flaw we are trying to fix after 'CeroWrt' is finished.
>
>> It seems the bufferbloat folks are blaming the high latencies on our
>> obsession on modern hardware to create huge queues and also with
>> software retries. They assert that reducing the queue length
>> (ATH_MAX_QDEPTH on ath9k) and software retries (ATH_MAX_SW_RETRIES on
>> ath9k) helps with latencies. They have at least empirically tested
>> this with ath9k with
>> a simple patch:

The retries in wireless interact here only because they have encouraged
buffering for the retries.  This is not unique to 802.11, but also
present in 3g networks (there, they fragment packets and put in lots of
buffering hoping to get the packet fragment transmitted at some future
time; they really hate dropping a packet if only a piece got damaged.


>> https://www.bufferbloat.net/attachments/43/580-ath9k_lowlatency.patch
>>
>> The obvious issue with this approach is it assumes STA mode of
>> operation, with an AP you do not want to reduce the queue size like
>> that. In fact because of the dynamic nature of 802.11 and the
> If there is any one assumption about the bufferbloat issue that people
> keep assuming we have, it's this one.
>
> In article after article, in blog post after blog post, people keep
> 'fixing' bufferbloat by setting their queues to very low values,
> and almost miraculously start seeing their  QoS start working
> (which it does), and then they gleefully publish their results
>  as recommendations, and then someone from the bufferbloat
> effort has to go and comment on that piece, whenever we
> notice, to straighten them out.
>
> In no presentation, no documentation, anywhere I know of,
> have we expressed  that queuing as it works today
> is the right thing.
>
> More recently, JG got fed up and wrote these...
>
> http://gettys.wordpress.com/2011/07/06/rant-warning-there-is-no-single-right-answer-for-buffering-ever/
>
> http://gettys.wordpress.com/2011/07/09/rant-warning-there-is-no-single-right-answer-for-buffering-ever-part-2/

Yes, I got really frustrated....

>
> There has been no time, since the inception of the bufferbloat
> concept, have we had a fixed buffer size in any layer of the
> stack as even a potential solution.

Right now, we have typically 2 (large) buffers: the transmit queue and
the driver rings.  Some hardware/software hides buffers in additional
places (e.g. on the OLPC X0-1, there are 4 packets in the wireless
module and 1 hidden in the driver itself. YMWV.
>
> And you just did applied that preconception to us again.
>
> My take on matters is that *unmanaged* buffer sizes > 1 is a
> problem. Others set the number higher.
>
> Of late, given what tools we have, we HAVE been trying to establish
> what *good baseline* queue sizes (txqueues, driver queues, etc)
> actually are for wireless under ANY circumstance that was
> duplicate-able.
>
> For the drivers JG was using last year, that answer was: 0.
>
> Actually, less than 0  would have been good, but that
> would have involved having tachyon emitters in the
> architecture.

Zero is what I set the transmit queue in my *experiments*  ***only***
because I knew by that point the drivers underneath the transmit queue
had another 250 or so packets of buffering on the hardware I (and most
of you) have; I went and looked at quite a few Linux drivers, and
confirmed similar ring buffer sizes on Mac and Windows both empirically
and when possible from driver control panel information.  At the
bandwidth delay product of my experiments, 250 packets is way more than
TCP will ever need.   See:
http://gettys.wordpress.com/2010/11/29/home-router-puzzle-piece-one-fun-with-your-switch/

Most current ethernet and wireless drivers have that much in the
transmit rings today, on all operating systems that I've played with.
The hardware will typically support up to 4096 packet rings, but the
defaults in the drivers seem to be typically in the 200-300 packet range
(sometimes per queue).

Remember that any long lived TCP session (an "elephant" flow), will fill
any size buffer just before the bottleneck link in a path, given time. 
It will fill the buffer at the rate at one packet/ack; in the traces I
took over cable modems you can watch the delay go up  and up cleanly,
and up (in my case, to 1.2 seconds when they filled after of order 10
seconds.  The same thing happens on 802.11 wireless, but its noisier in
my traces as I don't have a handy faraday cage ;-).  An additional
problem, which was a huge surprise to everyone who studied the traces is
that congestion avoidance is getting terminally confused.    And by
delaying packet drop (or ECN marking), TCP never slows down; it actually
continues to speed up (since current TCP algorithms typically do not
take notice of the RTT). The delay is so long that TCP's servo system is
no longer stable and it oscillates with a constant period.  I have no
clue if this is at all related to the other periodic behaviour people
have noticed.  If you think about it, the fact that the delay is several
orders of magnitude larger than the actual delay of the path makes it
less surprising than it might be.

Indeed there is no simple single right answer for buffering; it needs to
be dynamic, and ultimately we need to have AQM
even in hosts to control buffering (think about the case of two
different long lived TCP sessions over vastly different bandwidth/delay
paths).  The gotcha is we don't have a AQM algorithm known to work in
the face of the highly dynamic bandwidth variation that is wireless;
classic RED does not
have the output bandwidth as a parameter in its algorithm.  This was/is
the great surprise to me as I had always thought of AQM as a property of
internet routers, not hosts.

That buffering between the transmit queue is completely divorced from
driver buffering, when it needs to be treated together in some fashion. 
What the "right" way to do that is, I don't know, though Andrew's
interview gave me some hope.  And it needs to be dynamic, over (in the
802.11 case) at least 3 orders of magnitude.

This is a non-trivial, hard problem we have on our hands.

Computing the buffering in bytes is better than in packets; but since on
wireless multicast/broadcast is transmitted at a radically different
rate than other packets, I expect something based on time is really the
long term solution; and only the driver has any idea how long a packet
of a given flavour will likely take to transmit.
                    - Jim











--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
