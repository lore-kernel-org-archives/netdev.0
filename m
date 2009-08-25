From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@free.fr>
Subject: Re: [Bonding-devel] [PATCH net-next-2.6] bonding: introduce primary_lazy
 option
Date: Tue, 25 Aug 2009 22:33:47 +0200
Message-ID: <4A944AAB.6050504@free.fr>
References: <20090814105938.GE3457@psychotron.englab.brq.redhat.com> <4A859057.3020606@free.fr> <20090817114938.GA3416@psychotron.englab.brq.redhat.com> <4A89C3B1.3070509@free.fr> <20090818124550.GB3539@psychotron.englab.brq.redhat.com> <4A8D4427.8080004@free.fr> <20090824111619.GC4018@psychotron.englab.brq.redhat.com> <4A92ACA6.7070600@free.fr> <20090824152002.GD4018@psychotron.englab.brq.redhat.com> <697.1251135317@death.nxdomain.ibm.com> <20090825064351.GA3426@psychotron.englab.brq.redhat.com> <4A941FD9.6050304@free.fr> <16215.1251225681@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net, Jiri Pirko <jpirko@redhat.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.services.sfr.fr ([93.17.128.21]:8399 "EHLO
	smtp23.services.sfr.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755701AbZHYUdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 16:33:50 -0400
In-Reply-To: <16215.1251225681@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr> wrote:
>> Thinking about all that, I start feeling that some sort of user spac=
e system to=20
>> select the "best" slave would be better. If we can design a NETLINK =
interface to=20
>> report events (slave up, slave down...) to user space, then any user=
 space=20
>> daemon would be able to tell bonding what to do. Only if no process =
register to=20
>> receive those events would bonding use the normal slave selection ru=
les.
>=20
> 	This has been discussed more than once in the past, but hasn't
> ever really gotten anywhere.  I suspect the main impediment is the la=
ck
> of a suitable API.

Does a 'NETLINK for bonding' document, describing the proposed API, exi=
st ?

I imagine two different parts in the API :

1/ Everything related to configuration (set and read). This should be n=
ot far=20
from the current sysfs API.
2/ Event notification about "everything" that happens into bonding, to =
be able=20
to notify user space in real time.

It might be also interesting to use the netlink API to notify whoever i=
s=20
interested that a given not-enslaved interface just received a 802.3ad =
related=20
packet. This would allow for self enslavement of slaves into the same b=
ond, when=20
they happen to be connected to the same 802.3ad capable switch.

>> Designing such a NETLINK interface would replace my proposed weight =
option (at=20
>> least for best slave selection in active-backup mode and for best ag=
gregator=20
>> selection in 802.3ad mode). It would also solve the problem reported=
 by Jirka=20
>> and so replace the proposed primary_lazy option.
>=20
> 	Yes, a lot of the decision making at failover could be moved
> into a user space daemon.  The daemon, I think, should be optional; i=
f
> the basic selection policies are sufficient, then there's no need for=
 a
> trip to user space and back.
>=20
>> Any way, NETLINK is something that is supposed to come into bonding =
at some=20
>> times, because we know that the sysfs purists hate the sysfs bonding=
 stuff and=20
>> that NETLINK is the target to setup networking.
>=20
> 	I'm not a big fan of the sysfs API, either; it seemed like a
> good idea at the time.  It's certainly better than ifenslave in terms=
 of
> features, but some of it is pretty convoluted, and there are things t=
hat
> just can't be done from within sysfs.
>=20
> 	I recall seeing a note from Stephen Hemminger not too long ago
> (a month or two ago) that he was working on a netlink API for bonding=
,
> but I don't know how far that ever got.

Yes, I also read this note and remembered he detected that many things =
need to=20
be changed before... :-(

> 	One quesiton is, if a netlink API is implemented, whether to
> convert ifenslave, or deprecate ifenslave and put the various bonding
> functions into ip.

I suggest enhancing ip and removing ifenslave (or converting it to a sc=
ript that=20
would call ip internally, for backward compatibility). Why would we nee=
d a=20
dedicated tool for bonding ? We can even write this script now and use =
sysfs=20
instead of the ioctl, waiting for the netlink API.

> 	If a netlink API is on the relatively near horizon (say, within
> a few months), then I'm less inclined to put in the "lazy" option, si=
nce
> it would just become baggage carried forward for the next several yea=
rs
> (until the sysfs API could be deprecated and removed).

Does that mean you suggest Jiri works with Stephen on the netlink API ?=
 :-)

	Nicolas.

