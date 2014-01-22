From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 2/2] bonding: add netlink attributes to slave
 link dev
Date: Wed, 22 Jan 2014 09:22:15 +0100
Message-ID: <20140122082215.GA2814@minipsycho.orion>
References: <20140117065756.3194.70179.stgit@monster-03.cumulusnetworks.com>
 <20140121133426.GC3015@minipsycho.orion>
 <0A99CC69-DBFF-46DF-9300-D2C6DF10A965@cumulusnetworks.com>
 <20140121220016.GF3015@minipsycho.orion>
 <C5AA1F6D-4FC7-42F6-A59F-A0114E1B2E8B@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Ding Tianhong <dingtianhong@huawei.com>
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:64708 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbaAVIWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 03:22:19 -0500
Received: by mail-ee0-f52.google.com with SMTP id e53so4634962eek.39
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 00:22:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <C5AA1F6D-4FC7-42F6-A59F-A0114E1B2E8B@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 21, 2014 at 11:42:58PM CET, sfeldma@cumulusnetworks.com wrote:
>
>On Jan 21, 2014, at 2:00 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>
>> Tue, Jan 21, 2014 at 10:36:58PM CET, sfeldma@cumulusnetworks.com wro=
te:
>>>=20
>>> On Jan 21, 2014, at 5:34 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>=20
>>>>> +	if (rtnl_bond_slave_fill(skb, dev))
>>>>> +		goto nla_put_failure;
>>>>> +
>>>>=20
>>>> I must say I do not like this at all. This should be done in a gen=
eric
>>>> way. By a callback registered by bonding and possibly other master=
-slave
>>>> device types.
>>>=20
>>> The bond was registered with the ndo_get_slave op.  ndo_get_slave c=
ould be used for other master-slave device types.  I=E2=80=99ll agree t=
hat rtnl_bond_slave_fill() could have been written more generically.  I=
s that the objection?
>>=20
>> I think is should be done rather in rtnl_link_ops. It's the natural =
point
>> for this ops. I have patchset prepared. Will send it very soon.
>
>Ok, cool.
>
>Also, right now I have IFLA_SLAVE as a nest for IFLA_SLAVE_xxx attrs. =
 Do you think we should have a two-layer nest so we can capture other m=
aster-slave devices rather than just bond slaves?  I.e.:
>
>	IFLA_SLAVE
>		IFLA_BOND_SLAVE
>			IFLA_BOND_SLAVE_xxx
>			IFLA_BOND_SLAVE_yyy
>			IFLA_BOND_SLAVE_zzz
>		IFLA_FOO_SLAVE			// FOO is some other non-bond master
>			IFLA_FOO_SLAVE_xxx
>			IFLA_FOO_SLAVE_yyy
>			IFLA_FOO_SLAVE_zzz
>
>(Of course, slave wouldn=E2=80=99t be bond and foo slave at same time)=
=2E

I would rather do this in LINKINFO nest the same way IFLA_BOND_* are
done. Please see following patch:

http://patchwork.ozlabs.org/patch/313156/

>
>-scott
