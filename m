From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: gettime: Was (Re: Route cache performance under stress
Date: Wed, 11 Jun 2003 07:54:53 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611065255.L39678@shell.cyberus.ca>
References: <3EE682B8.8060708@candelatech.com> <20030610.182234.74725315.davem@redhat.com>
 <3EE68B15.60802@candelatech.com> <20030610.203325.41658167.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.203325.41658167.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, time to go into another separate thread ;->

Sounds like a good idea.

if (skbneedstimestamp)
	do_gettimeofday(&skb->stamp);
else
	defertimestamp()

For defertimestamp() would it be feasible that you store only the
jiffies value in the skb then get timeofday later and somehow
compensate for the difference? Seems very doable to me.

Question is when do you decide skbneedstimestamp?
Is it when the device is in promiscous mode or do it in ip or icmp etc?

cheers,
jamal


On Tue, 10 Jun 2003, David S. Miller wrote:

>    From: Ben Greear <greearb@candelatech.com>
>
>    Yes, I understand why we want a time-stamp very early...but if
>    we can get _some_ sort of time stamp very cheap (TSC, for example)
>    then we can potentially defer the more expensive conversion of
>    this stamp into the equivalent of whatever do_gettimeofday will
>    give us.
>
> I fully understand your idea, I've talked about it with Alexey many
> times.  Someone just has to implement it.
>
> pkt_sched.h is probably the place to play, maybe make an
> asm/pkt_sched.h header.
>
>
>
