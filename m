From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] sch_red: Adaptative RED AQM
Date: Thu, 8 Dec 2011 09:21:30 -0800
Message-ID: <20111208092130.656c39ff@nehalam.linuxnetplumber.net>
References: <CAA93jw7kQYONQiAozatRmdRRJeK0GB9eNDWtRZ3AL+OVKn0OpA@mail.gmail.com>
	<1323082774.2670.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1323360363.2521.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>,
	bloat-devel <bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	bloat <bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323360363.2521.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 08 Dec 2011 17:06:03 +0100
Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Changes against our RED implementation are :
> 
> max_p is no longer a negative power of two (1/(2^Plog)), but a Q0.32
> fixed point number, to allow full range described in Adatative paper.
> 
> To deliver a random number, we now use a reciprocal divide (thats really
> a multiply), but this operation is done once per marked/droped packet
> when in RED_BETWEEN_TRESH window, so added cost (compared to previous
> AND operation) is near zero.
> 
> dump operation gives current max_p value in a new TCA_RED_MAX_P
> attribute.
> 
> Example on a 10Mbit link :
> 
> tc qdisc add dev $DEV parent 1:1 handle 10: est 1sec 8sec red \
>    limit 400000 min 30000 max 90000 avpkt 1000 \
>    burst 55 ecn adaptative bandwidth 10Mbit
> 
> # tc -s -d qdisc show dev eth3
> ...
> qdisc red 10: parent 1:1 limit 400000b min 30000b max 90000b ecn
> adaptative ewma 5 max_p=0.113335 Scell_log 15
>  Sent 50414282 bytes 34504 pkt (dropped 35, overlimits 1392 requeues 0) 
>  rate 9749Kbit 831pps backlog 72056b 16p requeues 0 
>   marked 1357 early 35 pdrop 0 other 0
> 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Is this backward compatible for users that don't specify
an adaptive parameter.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
