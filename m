From: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Subject: Re: [PATCH v2 net-next 0/3] ipv4: Hash-based multipath routing
Date: Sat, 29 Aug 2015 13:59:08 -0700
Message-ID: <CALx6S35AUXFKfazU4bbpNL90r7P8i3wSFTB_0YDDRUgKg-3vqw@mail.gmail.com>
References: <1440792050-2109-1-git-send-email-pch@ordbogen.com>
	<20150829.131429.360433621593751136.davem@davemloft.net>
	<20150829223115.523553db@tyr>
	<20150829.134628.1013990034021542524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Christensen <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
	Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150829.134628.1013990034021542524.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 29, 2015 at 1:46 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wro=
te:
> From: Peter N=C3=B8rlund <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
> Date: Sat, 29 Aug 2015 22:31:15 +0200
>
>> On Sat, 29 Aug 2015 13:14:29 -0700 (PDT)
>> David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>>
>>> From: pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org
>>> Date: Fri, 28 Aug 2015 22:00:47 +0200
>>>
>>> > When the routing cache was removed in 3.6, the IPv4 multipath
>>> > algorithm changed from more or less being destination-based into
>>> > being quasi-random per-packet scheduling. This increases the risk
>>> > of out-of-order packets and makes it impossible to use multipath
>>> > together with anycast services.
>>>
>>> Don't even try to be fancy.
>>>
>>> Simply kill the round-robin stuff off completely, and make hash bas=
ed
>>> routing the one and only mode, no special configuration stuff
>>> necessary.
>>
>> I like the sound of that! Just to be clear - are you telling me to
>> stick with L3 and skip the L4 part?
>
> For now it seems best to just do L3 and make ipv4 and ipv6 behave the
> same.

This might be simpler if we just go directly to L4 which should be
better load balancing and what most switches are doing anyway. The
hash comes from:

1) If a lookup includes an skb, we just need to call skb_get_hash.
2) If we have a socket and sk->sk_txhash is nonzero then use that.
3) Else compute a hash frome flowi. We don't have the exact functions
for this, but they can be easily derived from __skb_get_hash_flowi4
and __skb_get_hash_flowi6 (i.e. create general get_hash_flowi4 and
get_hash_flowi6 and then call these from skb functions and multipath
lookup).

Tom

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
