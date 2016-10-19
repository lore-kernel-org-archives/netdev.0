From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [patch net-next RFC 4/6] Introduce sample tc action
Date: Wed, 19 Oct 2016 08:28:14 +0000
Message-ID: <AM3PR05MB0759EB89C599428761FA226AACD20@AM3PR05MB0759.eurprd05.prod.outlook.com>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
 <1476276069-5315-5-git-send-email-jiri@resnulli.us>
 <58025A90.9010608@cumulusnetworks.com>
 <81e49d64-e0bc-2f43-7a9c-daefb12a4b8a@mojatatu.com>
 <58056A08.5070809@cumulusnetworks.com>
 <DB3PR05MB0764DA26C8250B6C8DFD537CACD30@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <580721BF.4010303@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "geert+renesas@glider.be" <geert+renesas@glider.be>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "linux@roeck-us.net" <linux@roeck-us.net>,
        Shrijeet Mukherjee <shm@cumulusnetworks.com>,
        "Yotam Gigi" <yotam.gi@gmail.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0081.outbound.protection.outlook.com ([104.47.2.81]:15709
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756454AbcJSUoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Oct 2016 16:44:25 -0400
In-Reply-To: <580721BF.4010303@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Roopa Prabhu [mailto:roopa@cumulusnetworks.com]
>Sent: Wednesday, October 19, 2016 10:33 AM
>To: Yotam Gigi <yotamg@mellanox.com>
>Cc: Jamal Hadi Salim <jhs@mojatatu.com>; Jiri Pirko <jiri@resnulli.us>;
>netdev@vger.kernel.org; davem@davemloft.net; Ido Schimmel
><idosch@mellanox.com>; Elad Raz <eladr@mellanox.com>; Nogah Frankel
><nogahf@mellanox.com>; Or Gerlitz <ogerlitz@mellanox.com>;
>geert+renesas@glider.be; stephen@networkplumber.org;
>xiyou.wangcong@gmail.com; linux@roeck-us.net; Shrijeet Mukherjee
><shm@cumulusnetworks.com>; Yotam Gigi <yotam.gi@gmail.com>
>Subject: Re: [patch net-next RFC 4/6] Introduce sample tc action
>
>On 10/18/16, 3:58 AM, Yotam Gigi wrote:
>
>> On 16-10-15 12:34 PM, Roopa Prabhu wrote:
>[snip]
>
>>> The OVS implementation is a good example, the metadata includes all the
>>> actions applied
>>>>> to the packet in the kernel data path.
>>>>>
>>>> Again not sure what the use case would be (and why waste such space
>>>> especially when you are sending over the wire with such details).
>>> All this is being used currently.., But, this can be other api's sflow =
uses
>>> for monitoring.
>>> http://openvswitch.org/support/ovscon2014/17/1400-ovs-sflow.pdf
>>>
>>> Does not have to be part of the main/basic sampling api...
>>> it was just an example.
>>>
>> I guess that making the API extensible solves this, isn't it?
>
>yes, that might help...
>
>Just wanted to bring up the question/clarification on using mark again
>
>tc qdisc add dev eth1 handle ffff: ingress
>
>tc filter add dev eth1 parent ffff: \
>           matchall action sample rate 12 mark 17
>
>tc filter add parent ffff: dev eth1 protocol all \
>           u32 match mark 172 0xff
>           action mirred egress redirect dev dummy0
>
>Like we discussed @ netdev, mark can be used by other things in the system=
.
>A request to sample on an interface cannot be disruptive.
>Does this require mark to be not used elsewhere in the system when samplin=
g is
>enabled on an interface ?

I think the we can spare the usage of mark, or at least make it optional, a=
s the user
can match on the packets according to the eth_type (as part of the IFE, the=
 user=20
can set the sampled packet eth_type).

I will do that, and update the documentation as well.
