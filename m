From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: remove entries for master_ip and
 vlan_ip and query devices instead
Date: Fri, 16 Mar 2012 22:55:33 -0700 (PDT)
Message-ID: <20120316.225533.1194931730650486577.davem@davemloft.net>
References: <1331742069-16602-1-git-send-email-andy@greyhouse.net>
	<29983.1331859800@death.nxdomain>
	<CAHashqDhq20rqeOEdB0onOkV9yGF-dDKh22Ea4ra1KG21Uc9xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, ralf.zeidler@nsn.com
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754513Ab2CQFzo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 01:55:44 -0400
In-Reply-To: <CAHashqDhq20rqeOEdB0onOkV9yGF-dDKh22Ea4ra1KG21Uc9xQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andy Gospodarek <andy@greyhouse.net>
Date: Fri, 16 Mar 2012 09:48:23 -0400

> On Thu, Mar 15, 2012 at 9:03 PM, Jay Vosburgh <fubar@us.ibm.com> wrot=
e:
>>>@@ -2618,7 +2624,9 @@ static void bond_arp_send_all(struct bonding *=
bond, struct slave *slave)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!bond_vlan_used(bond)) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("basa: empty v=
lan: arp_send\n");
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond_arp_send(slave->de=
v, ARPOP_REQUEST, targets[i],
>>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0bond->master_ip, 0);
>>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0bond_confirm_addr(bond->dev,
>>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0targets[i],
>>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00), 0);
>>
>> =A0 =A0 =A0 =A0Same comment here and for the later calls to bond_con=
firm_addr,
>> here putting "targets[i]" and perhaps the 0 on the previous line,
>> although I'm less sure that it won't look funky.
>>
>> =A0 =A0 =A0 =A0-J
>>
>=20
> These we a bit tough to get looking great.  What I did really seemed
> like the best I could do and keep it to a reasonable length.  If you
> want me to just keep the length of these lines <100 characters wide, =
I
> could combine them into the same line.  Either way is fine with me,
> but I really just didn't want the code to get too wide and hard to
> read when using a standard size terminal.

It seems to me that the easiest thing to do is:

	__be32 addr =3D bond_confirm_addr(bond->dev, targets[i], 0);
	bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], addr, 0);

And actually this sequence is used in three places, so even better
to put it into a helper function.
