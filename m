From: Andre Tomt <andre@tomt.net>
Subject: Re: waiting for ppp0 to become free (Re: ppp0 out of control)
Date: Wed, 26 Jan 2005 11:02:54 +0100
Message-ID: <41F76ACE.3070405@tomt.net>
References: <20050121144444.GA2100@roxor.be> <20050126094422.GA31040@lk8rp.mail.xeon.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Janos Farkas <jf-ml-k1-1087813225@lk8rp.mail.xeon.eu.org>
In-Reply-To: <20050126094422.GA31040@lk8rp.mail.xeon.eu.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Janos Farkas wrote:
> On 2005-01-21 at 15:44:44, Aur=E9lien G=C9R=D4ME wrote:
>=20
>>I am running 2.6.10 from kernel.org on Debian Sid ppc/x86, the same
>>issue occurs with 2.6.9. Though, 2.6.8.1 and previous are fine.
>>
>>When my ISP connection via PPPoE (kernel side) goes down, reconnection
>>does not occur, and the kernel displays continuous:
>>
>>kernel: unregister_netdevice: waiting for ppp0 to become free. Usage co=
unt =3D 1
>=20
>=20
> BTW, I have seen many cases when this symptom annoyed me too, the last
> one is that my shutdown scripts tried unloading the network driver
> modules.  Is your setup doing this by any chance?  In my case,
> apparently there were conntrack entries keeping the device in use,
> which is almost useless when preparing to shutdown :)
>=20
> OTOH, I couldn't find a way to flush those conntracks, so I worked
> around it by not rmmoding ethernet drivers.
>=20
> In your case, it's probably conntrack too, I'd presume you are using
> that PPPoE machine as a masquerading gateway, which by definition needs
> connection tracking...  I'm not sure either if this is a "real" change,
> I only vaguely recollect as some moons earlier this wasn't a problem in
> 2.6.
>=20

Here's some data I've collected on a possible related or identical one.

So far it seems related to interface removal. I've seen this recently on=20
vlan interfaces, since ifupdown on my systems kill vlan devices on ifdown.

In my cases I've not been able to reproduce without ipv6 loaded in the=20
kernel, and it only seems to happen when lo/loopback is taken offline=20
first (ifdown -a here does it in that order..)

A shutdown rrmod-type takedown of a NIC would probably be run after=20
"ifdown -a", hence after lo is down, thats why I suspect it to be the=20
same problem.

I still have a binary search to do for pinpointing what broke it, though.
