From: jamal <hadi@cyberus.ca>
Subject: Re: bk16 changes to cbq
Date: 03 Jul 2004 21:21:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1088904111.1043.731.camel@jzny.localdomain>
References: <1088861810.1039.298.camel@jzny.localdomain>
	 <20040703101646.52ae1e01.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey <kuznet@ms2.inr.ac.ru>, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040703101646.52ae1e01.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, I looked at Stephens email; i found it here:
http://marc.theaimsgroup.com/?l=linux-netdev&m=108751387802077&w=2
Basically similar to what you said.
My suggestion is we back out this change - i think there may be a
problem elsewhere, somehow we end up pointing here. It is also possible
there was a hidden bug, but if this stuff was problematic we would have
had complaints in the last few years related.
The other thing is you can leave it in there and wait for people to
complain.

Lets say there was a race condition:
The worst that could happen in such a case (on TX completion) is that
the cbq watchdog is started (which later reschedules the device) and the
top layer reschedules the device as well(because the device was stopped;
stopped devices get descheduled). In such a case there will be two
netif_schedules() with one being unnecessary. No biggie, just a few
extra lines.

Lets say there was no race condition:
The cbq watchdog gets scheduled only when the netdevice is not stopped.
This is optimization is now gone.

To reiterate what i said earlier.
The only thing the tx complete can do is open up the device for
more packets to tx into the device... i.e !netif_queue_stopped(sch->dev)
is true in that specific case. 

Actually while looking at this i noticed some odd things; it may
be time to remind people of the return code rules on
dev->hard_start_xmit(). 

I will make another posting.

cheers,
jamal
