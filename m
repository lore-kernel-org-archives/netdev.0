From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [PATCH iproute2/net-next 1/3] tc: Add support for the sample tc
 action
Date: Sun, 5 Feb 2017 20:22:12 +0000
Message-ID: <DB3PR05MB076475ADE956B146B97EEECBAC410@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1486281534-61663-1-git-send-email-yotamg@mellanox.com>
 <1486281534-61663-2-git-send-email-yotamg@mellanox.com>
 <18afef7b-22f4-e37f-4ea3-99d8307a1eb7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: Florian Fainelli <f.fainelli@gmail.com>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00074.outbound.protection.outlook.com ([40.107.0.74]:45440
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753203AbdBEUWR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 5 Feb 2017 15:22:17 -0500
In-Reply-To: <18afef7b-22f4-e37f-4ea3-99d8307a1eb7@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Florian Fainelli [mailto:f.fainelli@gmail.com]
>Sent: Sunday, February 05, 2017 8:37 PM
>To: Yotam Gigi <yotamg@mellanox.com>; stephen@networkplumber.org;
>netdev@vger.kernel.org; Jiri Pirko <jiri@mellanox.com>; Elad Raz
><eladr@mellanox.com>
>Subject: Re: [PATCH iproute2/net-next 1/3] tc: Add support for the sample =
tc action
>
>On 02/04/2017 11:58 PM, Yotam Gigi wrote:
>> The sample tc action allows sampling packets matching a classifier. It
>> peeks randomly packets, and samples them using the psample netlink
>> channel. The user can specify the psample group, which the packet will b=
e
>> sampled to, the sampling rate and the packet truncation (to save
>> kernel-user traffic).
>>
>> The sampled packets contain informative metadata, for example, the input
>> interface and the original packet length.
>>
>> The action syntax:
>> tc filter add [...] \
>> 	action sample rate <RATE> group <GROUP> [trunc <SIZE>]
>> 	[...]
>>
>> Where:
>>   RATE :=3D The sampling rate which is the ratio of packets observed at =
the
>> 	  data source to the samples generated
>>   GROUP :=3D the psample module sampling group
>>   SIZE :=3D optional truncation size
>>
>> An example for a common usecase of the sample tc action: to sample ingre=
ss
>> traffic from interface eth1, one may use the commands:
>>
>> tc qdisc add dev eth1 handle ffff: ingress
>>
>> tc filter add dev eth1 parent ffff: \
>>        matchall action sample rate 12 group 4
>>
>> Where the first command adds an ingress qdisc and the second starts
>> sampling randomly with an average of one sampled packet per 12 packets
>> on dev eth1 to psample group 4.
>
>The group argument seems to be mandatory from looking at the code, but
>what if just wanted to have a port mirroring between, say sw0p1 and
>sw0p2 with the sample rate specified instead (without using the psample
>netlink channel at all)? Could we make this group an optional argument
>instead?

The kernel action currently don't support it, and I am not sure it should.

If I understand you correctly, you want to make the sample action identical
to mirred-mirror, only with random behavior. This can be done using the=20
matchall and mirred action, plus the 'random' gact keyword.=20

The sample action attaches some metadata in addition to the original packet
data, and that cannot be achieved by mirroring the packets, thus making it
unusable for our usecase. In the former version we attached the metadata
using the IFE protocol, but we decided to use a dedicated netlink channel=20
instead.

>
>Thanks!
>--
>Florian
