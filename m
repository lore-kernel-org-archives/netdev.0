From: jamal <hadi@cyberus.ca>
Subject: Re: packet re-ordering on SMP machines.
Date: Mon, 26 Aug 2002 07:20:47 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0208260710320.2028-100000@shell.cyberus.ca>
References: <3D69AFE7.6020902@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3D69AFE7.6020902@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




On Sun, 25 Aug 2002, Ben Greear wrote:

> jamal wrote:
>
> > That doesnt sound impressive at all. I know it's about .8 of wire rate
> > but you should be able to exceed that.
> > Robert was generating in the range of 800Kpps with that NIC if i recall
> > corectly
>
> I had only tested 1514 byte pkts, so I was getting around 880Mbps,
> which is pretty good as far as I know.

theres no reason you shouldnt be able to do wire rate.

>
> I see about 255 kpps when sending 64 byte pkts to myself.  Still
> dropping about 1 in 4000 packets at this speed.  I think most of Robert's
> tests didn't involve actually doing something with the received packet
> though, and I am inspecting it for latency, sequence number, etc.
>
> I'm even doing a __get_timeofday() call to calculate the latency...need
> to find a faster way to do that...
>

ouch.
for latency or sequencing you dont really need to all packets. Read
academic papers on the subject. You probably need about 5% of the total
packets. Also you dont have to do the checks at runtime, you can do them
once the run is complete (which you should be able to tell since you
control both send and receive).

> If I only allocate/scan 1 per 100 packets (ie alloc one packet and send it 100 times),
> then I get a more respectable 365kpps.  Robert's patch should definately help!
>

Yes, clearly you will benefit.

> > Also if you have SMP, tie each onto a CPU.
>
> That's with the irq_afinity thing in proc, right?

yes.

>
> > Additionaly get the skb recycler patch from Robert, it should improve
> > things even more.
>
> Do you happen to have a URL for this?
>
> Actually, the various network tweaks are relatively hard to find
> (at least to find the most up-to-date coppies).  It would be great if
> there was a place where they were all concentrated.

Roberts site is the main repository; it may have READMEs with URLs
pointing to various locations.
ftp://130.238.98.12/pub/Linux/net-development/
and look at the recycling and NAPI sub-directories.

>
> >
> >
> >>Also, I see the hard_start_xmit call failing 5876 times out of 2719493
> >>calls (for example).  The code that calls the method looks like this:
> >>
> >
> >
> > I dont have access to that NIC. But a stoopid question: Have you tried
> > increasing the transmit queue via ifconfig? 1000 packets is reasonable
> > for gige.
>
> I upped it, but it didn't stop the errors.  The NIC is still performing,
> so it may not be a real problem...
>

I dont have this NIC. When Robert shows up he may be able to explain this.

cheers,
jamal
