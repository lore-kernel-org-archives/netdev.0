From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Fri, 13 Feb 2004 02:34:05 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402130151020.1149@u.domain.uli>
References: <200402121937.WAA10800@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200402121937.WAA10800@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 12 Feb 2004 kuznet@ms2.inr.ac.ru wrote:

> Joining the discussion too late, but let me to reformulate original
> Jamal's question in another way: are you aware that you relay _broadcast_
> ARP requests doing the validation?

	Good question. It seems I misunderstood the goal of the
delaying mechanism.

> I really like the idea, but this aspect bothers me a lot. Is it not storm
> unsafe? Look, earlier broadcasts on outgoing interface started only when
> a real unicast IP traffic was pending, so we were sure sender selected some
> single proxy router, now broadcasts will be sent by _all_ the routers. See?

	Yep, 3 broadcasts per router for one requests which is 3 times
more than the current code sends in response to fake requests.

	I thought the delay is to lose the race with hosts with
this IP but now I see it is implemented as random delay. But we never
can guarantee that only one proxy router will serve the target IP - I see
the nice effect of using all proxy routers in parallel from
different senders. Any other hidden features? :)

	As for the proposed changes, any recommendations?
May be the flag for the incoming interface as Jamal requested
is already required if we still like to see these new features
in the kernel and running in a safe environment? Or it is
better to stay only with the current behaviour?

> Alexey

Regards

--
Julian Anastasov <ja@ssi.bg>
