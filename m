From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: creating netdev queues on the fly?
Date: Thu, 10 Nov 2011 17:26:09 +0100
Message-ID: <1320942369.3967.127.camel@jlt3.sipsolutions.net>
References: <1320933501.3967.68.camel@jlt3.sipsolutions.net>
	 <1320935713.2310.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 (sfid-20111110_153533_082549_9B566EB4)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1320935713.2310.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> (sfid-20111110_153533_082549_9B566EB4)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-11-10 at 15:35 +0100, Eric Dumazet wrote:

> > So to get to my question: What if we could create netdev queues on the
> > fly?

> In term of qdisc management I believe its a bit complex if we start to
> dynamically add netdev queues :)

Yeah I was thinking that would be the problematic part.

> My first idea would be to extend Qdisc management so that a device can
> callback qdisc when a frame is finaly delivered / consumed / discarded.
> 
> We currently only have qdisc->enqueue() and qdisc->dequeue(), we could
> add qdisc->deliver_callback(skb)
> 
> You keep devices as they are, with a netdevqueue per hardware queue.
> 
> Then, using a Qdisc like existing ones, but with a limit of
> outstanding(given to device but not yet consumed) packets per class.
> 
> external tc classifier would deliver a hash/index depending on remote
> station.

So basically you'd have a class for each station? Or a class for each
station/AC? That's a lot of classes rather than queues, are they
pre-allocated, or does it not matter? Overall that sounds like a good
approach.

> As a bonus you can get all the existing rate estimators / QOS /
> shapers ...

Yeah ... I guess I need to start learning tc :)

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
