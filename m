From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Fri, 16 Jul 2010 18:23:56 -0700
Message-ID: <AANLkTimk1TfddBqS8t1iApUNpsic7dZ0zfi9wtkjG82-@mail.gmail.com>
References: <4C3D94E3.9080103@wildgooses.com>
	<4C3DD5EB.9070908@tmr.com>
	<20100714.111553.104052157.davem@davemloft.net>
	<AANLkTil3MVGwJUG12dikut9X1s9Ozc_3GwMjx_gErvxI@mail.gmail.com>
	<1279299709.2156.5814.camel@tng>
	<4C4099D6.6020305@wildgooses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McManus <mcmanus@ducksong.com>,
	David Miller <davem@davemloft.net>, davidsen@tmr.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ed W <lists@wildgooses.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C4099D6.6020305@wildgooses.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 16, 2010 at 10:41 AM, Ed W <lists@wildgooses.com> wrote:
>
>> and while I'm asking for info, can you expand on the conclusion
>> regarding poor cache hit rates for reusing learned cwnds? (ok, I adm=
it I
>> only read the slides.. maybe the paper has more info?)
>>
>
> My guess is that this result is specific to google and their servers?
>
> I guess we can probably stereotype the world into two pools of device=
s:
>
> 1) Devices in a pool of fast networking, but connected to the rest of=
 the
> world through a relatively slow router
> 2) Devices connected via a high speed network and largely the bottlen=
eck
> device is many hops down the line and well away from us
>
> I'm thinking here 1) client users behind broadband routers, wireless,=
 3G,
> dialup, etc and 2) public servers that have obviously been deliberate=
ly
> placed in locations with high levels of interconnectivity.
>
> I think history information could be more useful for clients in categ=
ory 1)
> because there is a much higher probability that their most restrictiv=
e
> device is one hop away and hence affects all connections and relative=
ly
> occasionally the bottleneck is multiple hops away. =A0For devices in =
category
> 2) it's much harder because the restriction will usually be lots of h=
ops
> away and effectively you are trying to figure out and cache the speed=
 of
> every ADSL router out there... =A0For sure you can probably figure ou=
t how to
> cluster this stuff and say that pool there is 56K dialup, that pool t=
here is
> "broadband", that pool is cell phone, etc, but probably it's hard to =
do
> better than that?
>
> So my guess is this is why google have had poor results investigating=
 cwnd
> caching?

Actually we have investigated two type of caches, a short-history limit=
ed size
internal cache that is subject to some LRU replacement policy hence
much limiting
the cache hit rate, and a long-history external cache, which provides m=
uch more
accurate cwnd history per subnet but with high complexity and
deployment headache.

Also we have set out for a much more ambitious goal, to not just speed
up our own
services, but also provide a solution that could benefit the whole web
(see http://code.google.com/speed/index.html). The latter pretty much
precludes a complex
external cache scheme mentioned above.

Jerry

>
> However, I would suggest that whilst it's of little value for the ser=
ver
> side, it still remains a very interesting idea for the client side an=
d the
> cache hit ratio would seem to be dramatically higher here?
>
>
> I haven't studied the code, but given there is a userspace ability to=
 change
> init cwnd through the IP utility, it would seem likely that relativel=
y
> little coding would now be required to implement some kind of limited=
 cwnd
> caching and experiment with whether this is a valuable addition? =A0I=
 would
> have thought if you are only fiddling with devices behind a broadband=
 router
> then there is little chance of you "crashing the internet" with these=
 kind
> of experiments?
>
> Good luck
>
> Ed W
>
