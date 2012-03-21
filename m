From: Andy Gospodarek <gospo@redhat.com>
Subject: Re: [PATCH net-next] bonding: remove entries for master_ip and
 vlan_ip and query devices instead
Date: Wed, 21 Mar 2012 12:25:53 -0400
Message-ID: <20120321162553.GA11165@quad.redhat.com>
References: <1331742069-16602-1-git-send-email-andy@greyhouse.net>
 <29983.1331859800@death.nxdomain>
 <CAHashqDhq20rqeOEdB0onOkV9yGF-dDKh22Ea4ra1KG21Uc9xQ@mail.gmail.com>
 <20120316.225533.1194931730650486577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andy@greyhouse.net, fubar@us.ibm.com, netdev@vger.kernel.org,
	ralf.zeidler@nsn.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43145 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755585Ab2CUTLj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2012 15:11:39 -0400
Content-Disposition: inline
In-Reply-To: <20120316.225533.1194931730650486577.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 16, 2012 at 10:55:33PM -0700, David Miller wrote:
> From: Andy Gospodarek <andy@greyhouse.net>
> Date: Fri, 16 Mar 2012 09:48:23 -0400
>=20
> > On Thu, Mar 15, 2012 at 9:03 PM, Jay Vosburgh <fubar@us.ibm.com> wr=
ote:
> >>>@@ -2618,7 +2624,9 @@ static void bond_arp_send_all(struct bonding=
 *bond, struct slave *slave)
> >>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!bond_vlan_used(bond)) {
> >>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("basa: empty=
 vlan: arp_send\n");
> >>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond_arp_send(slave->=
dev, ARPOP_REQUEST, targets[i],
> >>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0bond->master_ip, 0);
> >>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0bond_confirm_addr(bond->dev,
> >>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0targets[i],
> >>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00), 0);
> >>
> >> =A0 =A0 =A0 =A0Same comment here and for the later calls to bond_c=
onfirm_addr,
> >> here putting "targets[i]" and perhaps the 0 on the previous line,
> >> although I'm less sure that it won't look funky.
> >>
> >> =A0 =A0 =A0 =A0-J
> >>
> >=20
> > These we a bit tough to get looking great.  What I did really seeme=
d
> > like the best I could do and keep it to a reasonable length.  If yo=
u
> > want me to just keep the length of these lines <100 characters wide=
, I
> > could combine them into the same line.  Either way is fine with me,
> > but I really just didn't want the code to get too wide and hard to
> > read when using a standard size terminal.
>=20
> It seems to me that the easiest thing to do is:
>=20
> 	__be32 addr =3D bond_confirm_addr(bond->dev, targets[i], 0);
> 	bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], addr, 0);
>=20
> And actually this sequence is used in three places, so even better
> to put it into a helper function.

=46or readability it makes sense to pop this function out like you have
suggested.  I'm not sure I want to make a helper function for both
calls, but I'll take a look at post an update patch.
