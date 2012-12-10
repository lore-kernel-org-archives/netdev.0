From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] ipv4: ip_check_defrag must not modify skb before
 unsharing
Date: Mon, 10 Dec 2012 13:50:14 -0500 (EST)
Message-ID: <20121210.135014.574510727443547729.davem@davemloft.net>
References: <1355132466.9857.6.camel@jlt4.sipsolutions.net>
	<20121210.134146.1583909966821253233.davem@davemloft.net>
	<1355165152.8083.4.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric-EVVnsjFE0OfYtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1355165152.8083.4.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Mon, 10 Dec 2012 19:45:52 +0100

> On Mon, 2012-12-10 at 13:41 -0500, David Miller wrote:
>> So the bug is that ip_check_defrag() has a precondition which is met
>> properly by all callers except AF_PACKET.
>> 
>> If this is the case, remind me why are we changing ip_check_defrag()
>> rather than the violator of the precondition?
> 
> I don't think this is the case.
> 
> If you're referring to my note about af_packet: the kernels where this
> goes into af_packet.c are the kernels that don't even have
> ip_check_defrag() because macvlan didn't exist/didn't have ip defrag
> support and af_packet had this code there -- see commit bc416d9768a.
> 
> If you're not referring to my note about af_packet: both callers (there
> are only two) of ip_check_defrag() have this bug as far as I can tell
> because they're both in the part of the RX path where shared SKBs might
> happen.

You're right, I misinterpreted what's happening here.

My misunderstanding was that this was a situation where normal IPV4
input processing makes sure the SKB is unshared, and we had special
code paths that didn't make sure that was the case.

Rather, here, we have a special entrypoint for macvlan and AF_PACKET
which is supposed to take care of such issues since it is known to
execute in a different kind of environment.

I'm pretty sure I'll apply this, after I check a few more things,
thanks Johannes!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
