From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [patch net-next v2 5/8] Introduce sample tc action
Date: Wed, 4 Jan 2017 11:01:46 +0000
Message-ID: <DB3PR05MB0764CDAD9E240CCD3438EE8BAC610@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
 <1479135638-3580-6-git-send-email-jiri@resnulli.us>
 <582C861B.8010709@cumulusnetworks.com>
 <DB3PR05MB0764183033BE8FFDAC8B6896ACBE0@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <20170104104251.GB30008@penelope.horms.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "geert+renesas@glider.be" <geert+renesas@glider.be>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "linux@roeck-us.net" <linux@roeck-us.net>,
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0060.outbound.protection.outlook.com ([104.47.0.60]:24000
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S964806AbdADLCP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 06:02:15 -0500
In-Reply-To: <20170104104251.GB30008@penelope.horms.nl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Simon Horman [mailto:simon.horman@netronome.com]
>Sent: Wednesday, January 04, 2017 12:43 PM
>To: Yotam Gigi <yotamg@mellanox.com>
>Cc: Roopa Prabhu <roopa@cumulusnetworks.com>; Jiri Pirko <jiri@resnulli.us=
>;
>netdev@vger.kernel.org; davem@davemloft.net; Ido Schimmel
><idosch@mellanox.com>; Elad Raz <eladr@mellanox.com>; Nogah Frankel
><nogahf@mellanox.com>; Or Gerlitz <orlitz@mellanox.com>;
>jhs@mojatatu.com; geert+renesas@glider.be; stephen@networkplumber.org;
>xiyou.wangcong@gmail.com; linux@roeck-us.net; john.fastabend@gmail.com
>Subject: Re: [patch net-next v2 5/8] Introduce sample tc action
>
>On Wed, Nov 16, 2016 at 04:26:44PM +0000, Yotam Gigi wrote:
>> >-----Original Message-----
>> >From: Roopa Prabhu [mailto:roopa@cumulusnetworks.com]
>> >Sent: Wednesday, November 16, 2016 6:15 PM
>> >To: Jiri Pirko <jiri@resnulli.us>
>> >Cc: netdev@vger.kernel.org; davem@davemloft.net; Yotam Gigi
>> ><yotamg@mellanox.com>; Ido Schimmel <idosch@mellanox.com>; Elad Raz
>> ><eladr@mellanox.com>; Nogah Frankel <nogahf@mellanox.com>; Or Gerlitz
>> ><ogerlitz@mellanox.com>; jhs@mojatatu.com; geert+renesas@glider.be;
>> >stephen@networkplumber.org; xiyou.wangcong@gmail.com; linux@roeck-
>us.net;
>> >john.fastabend@gmail.com; simon.horman@netronome.com
>> >Subject: Re: [patch net-next v2 5/8] Introduce sample tc action
>> >
>> >On 11/14/16, 7:00 AM, Jiri Pirko wrote:
>> >> From: Yotam Gigi <yotamg@mellanox.com>
>> >>
>> >> This action allow the user to sample traffic matched by tc classifier=
.
>> >> The sampling consists of choosing packets randomly, truncating them,
>> >> adding some informative metadata regarding the interface and the orig=
inal
>> >> packet size and mark them with specific mark, to allow further tc rul=
es to
>> >> match and process. The marked sample packets are then injected into t=
he
>> >> device ingress qdisc using netif_receive_skb.
>> >>
>> >> The packets metadata is packed using the ife encapsulation protocol, =
and
>> >> the outer packet's ethernet dest, source and eth_type, along with the
>> >> rate, mark and the optional truncation size can be configured from
>> >> userspace.
>> >>
>> >> Example:
>> >> To sample ingress traffic from interface eth1, and redirect the sampl=
ed
>> >> the sampled packets to interface dummy0, one may use the commands:
>> >>
>> >> tc qdisc add dev eth1 handle ffff: ingress
>> >>
>> >> tc filter add dev eth1 parent ffff: \
>> >> 	   matchall action sample rate 12 mark 17
>> >
>> >Yotham, I am guessing in the future if one does not want to use mark,
>> >the sample api is extensible to allow for other actions to be added.
>> >This is from the general concern we had on using mark: some may not wan=
t to
>use
>> >mark.
>> >As long as the api is extensible to allow an alternate way in the futur=
e,
>> > we should be good. (We would prefer to not go down the path of having =
to
>> >introduce
>> >a new  'action sample' if this limits us in some way).
>>
>> The code is extensible  - if one does want to add another action to samp=
le, he
>> totally can :)
>>
>> By the way, one of the reasons we removed the patches for now is that we
>> consider adding mirroring functionality to it instead of heaving two tc-=
rules.
>
>Hi Yotham,
>
>I see that this action combines several discrete sub-actions, some of whic=
h
>duplicate functionality present in existing actions:
>
>* sample
>* truncate
>* IFE encapsulation with metadata
>* mark
>* output (proposed)
>
>I wonder if it would make sense to provided a mechanism whereby sampled
>packets can be passed on to other actions. Something similar to the
>existing pipe mechanism but allowing for the sampled and the original pack=
ets
>to continue to be processed separately.
>
>If so, it may be worth white-listing actions for which sampled packets are
>known to work well to limit the scope for unforseen side effects.

Hi Simon,

The patches were removed and we intend to propose a different implementatio=
n for
that, using a dedicated sampling netlink channel, thus removing the need to
mark, mirror and IFE-pack the packets.

We intend to send in the next few weeks, so I guess you can comment on the =
new
version.

Thanks!
