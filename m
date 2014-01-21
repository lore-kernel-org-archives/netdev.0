From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/2] bonding: add netlink attributes to slave link dev
Date: Tue, 21 Jan 2014 14:42:58 -0800
Message-ID: <C5AA1F6D-4FC7-42F6-A59F-A0114E1B2E8B@cumulusnetworks.com>
References: <20140117065756.3194.70179.stgit@monster-03.cumulusnetworks.com> <20140121133426.GC3015@minipsycho.orion> <0A99CC69-DBFF-46DF-9300-D2C6DF10A965@cumulusnetworks.com> <20140121220016.GF3015@minipsycho.orion>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Ding Tianhong <dingtianhong@huawei.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:49156 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331AbaAUWnE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 17:43:04 -0500
In-Reply-To: <20140121220016.GF3015@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 21, 2014, at 2:00 PM, Jiri Pirko <jiri@resnulli.us> wrote:

> Tue, Jan 21, 2014 at 10:36:58PM CET, sfeldma@cumulusnetworks.com wrot=
e:
>>=20
>> On Jan 21, 2014, at 5:34 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>=20
>>>> +	if (rtnl_bond_slave_fill(skb, dev))
>>>> +		goto nla_put_failure;
>>>> +
>>>=20
>>> I must say I do not like this at all. This should be done in a gene=
ric
>>> way. By a callback registered by bonding and possibly other master-=
slave
>>> device types.
>>=20
>> The bond was registered with the ndo_get_slave op.  ndo_get_slave co=
uld be used for other master-slave device types.  I=92ll agree that rtn=
l_bond_slave_fill() could have been written more generically.  Is that =
the objection?
>=20
> I think is should be done rather in rtnl_link_ops. It's the natural p=
oint
> for this ops. I have patchset prepared. Will send it very soon.

Ok, cool.

Also, right now I have IFLA_SLAVE as a nest for IFLA_SLAVE_xxx attrs.  =
Do you think we should have a two-layer nest so we can capture other ma=
ster-slave devices rather than just bond slaves?  I.e.:

	IFLA_SLAVE
		IFLA_BOND_SLAVE
			IFLA_BOND_SLAVE_xxx
			IFLA_BOND_SLAVE_yyy
			IFLA_BOND_SLAVE_zzz
		IFLA_FOO_SLAVE			// FOO is some other non-bond master
			IFLA_FOO_SLAVE_xxx
			IFLA_FOO_SLAVE_yyy
			IFLA_FOO_SLAVE_zzz

(Of course, slave wouldn=92t be bond and foo slave at same time).

-scott