From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]: Adjust qlen when grafting in multiple qdiscs
Date: 17 Nov 2003 12:30:10 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1069090210.1022.64.camel@jzny.localdomain>
References: <3FB3996A.6080008@trash.net>
	 <1069076786.1075.19.camel@jzny.localdomain>  <3FB8DDE0.1070105@trash.net>
	 <1069081153.1022.20.camel@jzny.localdomain>  <3FB8F3BF.6050509@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3FB8F3BF.6050509@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick,

What happens if you add another type of qdisc example RED (after you
have deleted pfifo? Not that it makes a lot of sense to add anything
than a simple FIFO or even makes sense to add a leaf qdisc to begin
with).
My opinion is that since these interfaces (ex qdisc) exist they
exist to be (ab)used. 
Dsmark happens to work well with the single queue - maybe thats what
needs to be documented as opposed to saying it deviates from a purist
angle.

Lets hear what the author of dsmark says. Werner?

cheers,
jamal

PS: Again please note i didnt pay close attention to your other changes;
so test them accordingly.

On Mon, 2003-11-17 at 11:13, Patrick McHardy wrote:
> Hi Jamal,
> 
> the patch was meant to fix the problem that when replacing (or deleting)
> a leaf queue that still holds packets the packets are not subtracted
> from the upper queue's q.qlen. dsmark_reset does set the length to 0 but
> it is not called when grafting. I've now verified experimentally the
> problem also exists in dsmark:
> 
> # tc qdisc add dev eth0 root handle 1: dsmark indices 64
> # tc qdisc add dev eth0 parent 1: pfifo limit 100
> # netperf -H 192.168.0.1
> < queue is holding 38 packets at this moment >
> # tc qdisc del dev eth0 parent 1: pfifo
> # tc qdisc add dev eth0 parent 1: pfifo limit 100
> # tc -s -d qdisc show dev eth0
> 
> qdisc pfifo 800d: limit 100p
>  Sent 296729221 bytes 854680 pkts (dropped 0, overlimits 0)
>  backlog 33p
>                                                                                 
> qdisc dsmark 1: indices 0x0040
>  Sent 510414473 bytes 1489414 pkts (dropped 40, overlimits 0)
>  backlog 71p
> 
> While it may not be a common operation or not even make sense, it is a
> valid one and IMHO should be handled correctly. It actually did happen
> to me while playing with TBF. I missed dsmark only has a single queue
> so sch->q.qlen = 0 would be ok in dsmark_graft. If you're ok with that,
> I'm going to change the patch.
> 
> Best regards,
> Patrick
> 
> 
> jamal wrote:
> 
> >Patrick,
> >
> >It doesnt make sense to have more than one queue in Dsmark (used as a
> >place holder/work queue while DSCP remarking). 
> >If reset() is already setting the length to 0 then it is not useful
> >to set it to anything else (it may actually become a -ve number).
> >I would suggest you use some of the examples in
> >iproute2/examples/diffserv to test things out (for all your changes -
> >the dsmark change was staring at me in the face - i didnt pay attention
> >to the rest).
> >
> >cheers,
> >jamal
> >  
> >
> 
> 
> 
