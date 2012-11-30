From: Dries De Winter <dries.dewinter@gmail.com>
Subject: Re: [PATCH] net: ICMPv6 packets transmitted on wrong interface if
 nfmark is mangled
Date: Fri, 30 Nov 2012 13:29:20 +0100
Message-ID: <CA+e04fhY1KjYFwbQ6P=V==kyU3fqMrvrzRJSyz6sy=RwHki07Q@mail.gmail.com>
References: <22884633.2468.1354092935228.JavaMail.driesdw@sahwcmp0020>
	<14515182.2480.1354093791878.JavaMail.driesdw@sahwcmp0020>
	<20121128.183037.1780631404801131036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pablo@netfilter.org, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20121128.183037.1780631404801131036.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/11/29 David Miller <davem@davemloft.net>:
> From: Dries De Winter <dries.dewinter@gmail.com>
> Date: Wed, 28 Nov 2012 10:09:55 +0100 (CET)
>
>> I propose a patch which allows to mark a dst_entry as "non-reroutable".
>> icmp6_dst_alloc() (used by ndisc and MLD implementation) will always mark
>> the
>> allocated dst_entry as such. A check is added to netfilter (IPv6-only) so
>> packets heading for a non-reroutable destination are never rerouted.
>
> What about addrconf_dst_alloc()?  Shouldn't it have this new flag set
> as well?
I don't think so. I'm not sure if I understand all of IPv6 routing
correctly, but it looks like dst entries allocated by
addrconf_dst_alloc() are added to the routing table pretty much like
normal routes and skbuffs get assigned such dst entries by normal rule
lookup / route lookup.

If an skbuff got assigned such a dst entry by normal routing in the
first place, and the changes done by the mangle table don't affect
routing (e.g. skb->mark changed but no policy based routing), I guess
that rerouting the packet will get you there too. In the meantime, by
not specifying DST_NOREROUTE for such destinations, you don't lose the
capability to mangle a packet so it should really be routed
differently.

> Regardless of the answer to that question, it should be explained
> in the commit message.
Should I post a new patch email including this comment?

Regards,

Dries.
