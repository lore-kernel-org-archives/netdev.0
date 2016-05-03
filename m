From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] block/drbd: use nla_put_u64_64bit()
Date: Tue, 3 May 2016 14:07:04 +0200
Message-ID: <57289468.5090401@6wind.com>
References: <57286F49.8050107@6wind.com>
 <1462268358-19044-1-git-send-email-nicolas.dichtel@6wind.com>
 <20160503100644.GE16459@soda.linbit>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, davem@davemloft.net,
	philipp.reisner@linbit.com, drbd-dev@lists.linbit.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160503100644.GE16459@soda.linbit>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 03/05/2016 12:06, Lars Ellenberg a =E9crit :
> On Tue, May 03, 2016 at 11:39:18AM +0200, Nicolas Dichtel wrote:
>> Two new handlers have been defined in genl_magic_ headers:
>>  - __field2: the corresponding nla_put() function (nla_put_flag()) t=
akes
>>              only two args
>>  - __field4: the corresponding nla_put() function (nla_put_u64_64bit=
())
>>              takes four args
>>
>> __field2 allows us to define __unspec_field for padding attribute.
>> __field4 allows us to update the definition of __u64_field: the pad
>> attribute should now be specified.
>=20
> Please just NOT use an additional "field",
> but always use 0 to pad.
>=20
> Patch is much shorter as well, see below.
I don't think that the goal is to make the shortest patch...
But frankly, I don't care. The goal was to use the new interface in a p=
roper
way, like every other subsystem.

>=20
> Attribute type "0" is not used,
> and will never be of semantic value,
> but always be ignored in the DRBD netlink family.
>=20
> Whereas using some arbitrary value will be wrong,
> and will needlessly break userland.
An application should always ignore unknown attribute, this is a golden=
 rule.
Now if you know that this patch will break applications (which one exac=
tly?), we
can use your proposal.


Regards,
Nicolas
