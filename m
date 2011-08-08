From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: Bonding problem
Date: Mon, 8 Aug 2011 13:31:02 -0400
Message-ID: <20110808173101.GU21309@gospo.rdu.redhat.com>
References: <CANMAZFUibmkyfWP2TyjwV6wtox6LNry2Gh3AtXB2KHnhGF80rQ@mail.gmail.com> <20110808162645.GT21309@gospo.rdu.redhat.com> <26478.1312823165@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Eduard Sinelnikov <eduard.sinelnikov@gmail.com>,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8176 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751773Ab1HHRbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 13:31:07 -0400
Content-Disposition: inline
In-Reply-To: <26478.1312823165@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 08, 2011 at 10:06:05AM -0700, Jay Vosburgh wrote:
>=20
> Andy Gospodarek <andy@greyhouse.net> wrote:
>=20
> >On Sun, Aug 07, 2011 at 03:00:30PM +0300, Eduard Sinelnikov wrote:
> >> Hi,
> >>=20
> >> In the kernel 2.6.39.3 ( /drivers/net/bond/bond_main.c).
> >> In the function =C2=A0=E2=80=98bond_xmit_roundrobin=E2=80=99
> >> The code check if the bond is active via
> >> =E2=80=98bond_is_active_slave(slave)=E2=80=99 Function call.
> >> Which actually checks if the slave is backup or active
> >> What is the meaning of slave being =C2=A0backup in round robin mod=
e?
> >> Correct me if I wrong but in round robin every slave should send a
> >> packet, regardless of being active or backup.
> >>=20
> >> Thank you,
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Eduard
> >
> >There probably is not a compelling reason to continue to have it.  T=
here
> >may be a reason historically, but I'm not aware what that might be a=
t
> >this point.  For modes other than active-backup, the value of
> >slave->link and slave->backup should always contain a value that
> >indicates the slave is up and available for transmit.
>=20
> 	If you read Eduard's other posts regarding this, the actual
> issue is that when changing from another mode into round-robin,
> occasionally slaves will still be marked as "backup" and won't be use=
d:
>=20

I did notice that one after I sent this first response.

> >Date: 	Mon, 8 Aug 2011 11:16:39 +0300
> >Subject: On line Bonding configuration change fails
> >From: Eduard Sinelnikov <eduard.sinelnikov@gmail.com>
> >To: netdev@vger.kernel.org
> >Sender: netdev-owner@vger.kernel.org
> >
> >Hi,
> >
> >My configuration is a follows:
> >
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| eth0 -------------=
->
> >Ububntu | eth1 --------------> =C2=A0 =C2=A0Swith ------------> Othe=
r computer
> >
> >Scenario:
> >=E2=80=A2 change the bond mode to active/backup
> >=E2=80=A2 unplug some of the cable
> >=E2=80=A2 plug-in the unplugged cable
> >=E2=80=A2 change bond mode to round robin
> >
> >I can see that only one eth1 is sending data. When I unplug it the p=
ing stops.
> >
> >Is it a bug or some mis-configuration?
> >
> >In the kernel ( /drivers/net/bond/bond_main.c).
> >In the function =C2=A0=E2=80=98bond_xmit_roundrobin
> >=E2=80=99
> >The code check if the bond is active via
> >=E2=80=98bond_is_active_slave(slave)=E2=80=99 Function call.
> >Which actually checks if the slave is backup or active
> >What is the meaning of backup in round robin?
> >Correct me if I wrong but in round robin every slave should send a
> >packet, regardless of being active or backup.
>=20
> 	So from looking at the code, it seems that the actual problem is
> that when transitioning to round-robin mode, one or more slaves can
> remain marked as "backup," and in round-robin mode, that won't ever
> change.  We could probably work around that by removing the "is_activ=
e"
> test (essentially declaring that "is_active" is only valid in
> active-backup mode).  That might produce a few odd messages here and
> there (when removing a slave or during a link failure, for example).
>=20
> 	From inspection, the bond_xmit_xor function likely has this same
> problem.
>=20

Agreed.

> 	-J
>=20
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
