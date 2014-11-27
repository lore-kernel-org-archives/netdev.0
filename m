From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next v2 05/10] rocker: introduce rocker switch driver
Date: Thu, 27 Nov 2014 06:09:11 -0800
Message-ID: <54773087.5060309@gmail.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-6-git-send-email-jiri@resnulli.us> <5461366A.9050900@gmail.com> <20141111142946.GG19157@casper.infradead.org> <20141111151928.GF1825@nanopsycho.lan> <20141111153232.GH19157@casper.infradead.org> <20141111154017.GH1825@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcr
To: Jiri Pirko <jiri@resnulli.us>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:42850 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbaK0GJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 01:09:17 -0500
Received: by mail-oi0-f47.google.com with SMTP id v63so3081517oia.34
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 22:09:17 -0800 (PST)
In-Reply-To: <20141111154017.GH1825@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/11/2014 07:40, Jiri Pirko a =E9crit :
> Tue, Nov 11, 2014 at 04:32:32PM CET, tgraf@suug.ch wrote:
>> On 11/11/14 at 04:19pm, Jiri Pirko wrote:
>>> Tue, Nov 11, 2014 at 03:29:46PM CET, tgraf@suug.ch wrote:
>>>> On 11/10/14 at 02:04pm, John Fastabend wrote:
>>>>> On 11/09/2014 02:51 AM, Jiri Pirko wrote:
>>>>>> +static int rocker_port_sw_parent_id_get(struct net_device *dev,
>>>>>> +					struct netdev_phys_item_id *psid)
>>>>>> +{
>>>>>> +	struct rocker_port *rocker_port =3D netdev_priv(dev);
>>>>>> +	struct rocker *rocker =3D rocker_port->rocker;
>>>>>> +
>>>>>
>>>>> hmm looks like you read this out of a magic switch register :) bu=
t
>>>>> my switch doesn't have this magic reg. I suposse the switch MAC a=
ddress
>>>>> should work.
>>>>
>>>> This needs more work afterwards. Either we define that the switch =
ID
>>>> is only unique in combination with the parent ifindex or we need t=
o
>>>> introduce a notation of uniquness into the switch ID itself.
>>>
>>> This is something similar to physical port id. Each driver should t=
ake
>>> care of generating that id.
>>
>> If the ID is only unique within a driver, then the user space cannot
>> rely on using the ID to group switch ports. Multiple drivers might
>> come up with the same ID.
>=20
> Well, as I said, it is the same as for physical port id. But if neede=
d,
> there can be added some simple mechanism for the id registration
> ensuring their uniqueness.

We could use the idr/ida subsystem to provide a global unique id per
switch device that gets registered, ultimately, I suspect that a
management application might want to get some sense of the topology by
exploiting some unique HW properties such as:

- MDIO bus address for MDIO-connected switches
- SPI chip-select address
- GPIO(s) used to connect
- PCI bus/slot

they are also unique by design, and add to that any revision/OUI
register that is available for the driver. I can't find of a good way t=
o
hash that to produce a unique identifier, but maybe we can use that
information somehow.

>=20
>>
>> Even now, multiple rocker instances would have the same ID.
>=20
> It depends on what hw returns to driver.
>=20
