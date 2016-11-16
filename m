From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [patch net-next v2 5/8] Introduce sample tc action
Date: Wed, 16 Nov 2016 16:26:44 +0000
Message-ID: <DB3PR05MB0764183033BE8FFDAC8B6896ACBE0@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
 <1479135638-3580-6-git-send-email-jiri@resnulli.us>
 <582C861B.8010709@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
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
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "simon.horman@netronome.com" <simon.horman@netronome.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0076.outbound.protection.outlook.com ([104.47.2.76]:21388
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932247AbcKPQlm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 11:41:42 -0500
In-Reply-To: <582C861B.8010709@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Roopa Prabhu [mailto:roopa@cumulusnetworks.com]
>Sent: Wednesday, November 16, 2016 6:15 PM
>To: Jiri Pirko <jiri@resnulli.us>
>Cc: netdev@vger.kernel.org; davem@davemloft.net; Yotam Gigi
><yotamg@mellanox.com>; Ido Schimmel <idosch@mellanox.com>; Elad Raz
><eladr@mellanox.com>; Nogah Frankel <nogahf@mellanox.com>; Or Gerlitz
><ogerlitz@mellanox.com>; jhs@mojatatu.com; geert+renesas@glider.be;
>stephen@networkplumber.org; xiyou.wangcong@gmail.com; linux@roeck-us.net;
>john.fastabend@gmail.com; simon.horman@netronome.com
>Subject: Re: [patch net-next v2 5/8] Introduce sample tc action
>
>On 11/14/16, 7:00 AM, Jiri Pirko wrote:
>> From: Yotam Gigi <yotamg@mellanox.com>
>>
>> This action allow the user to sample traffic matched by tc classifier.
>> The sampling consists of choosing packets randomly, truncating them,
>> adding some informative metadata regarding the interface and the origina=
l
>> packet size and mark them with specific mark, to allow further tc rules =
to
>> match and process. The marked sample packets are then injected into the
>> device ingress qdisc using netif_receive_skb.
>>
>> The packets metadata is packed using the ife encapsulation protocol, and
>> the outer packet's ethernet dest, source and eth_type, along with the
>> rate, mark and the optional truncation size can be configured from
>> userspace.
>>
>> Example:
>> To sample ingress traffic from interface eth1, and redirect the sampled
>> the sampled packets to interface dummy0, one may use the commands:
>>
>> tc qdisc add dev eth1 handle ffff: ingress
>>
>> tc filter add dev eth1 parent ffff: \
>> 	   matchall action sample rate 12 mark 17
>
>Yotham, I am guessing in the future if one does not want to use mark,
>the sample api is extensible to allow for other actions to be added.
>This is from the general concern we had on using mark: some may not want t=
o use
>mark.
>As long as the api is extensible to allow an alternate way in the future,
> we should be good. (We would prefer to not go down the path of having to
>introduce
>a new  'action sample' if this limits us in some way).

The code is extensible  - if one does want to add another action to sample,=
 he=20
totally can :)

By the way, one of the reasons we removed the patches for now is that we=20
consider adding mirroring functionality to it instead of heaving two tc-rul=
es.


>
>>
>> tc filter add parent ffff: dev eth1 protocol all \
>> 	   u32 match mark 17 0xff \
>> 	   action mirred egress redirect dev dummy0
>>
>
>thanks.
