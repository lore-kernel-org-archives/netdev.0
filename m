From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC 0/4] RFC: Add Checmate, BPF-driven minor LSM
Date: Mon, 15 Aug 2016 12:59:13 +0200
Message-ID: <57B1A081.9030209@digikod.net>
References: <20160804071116.GA19098@ircssh.c.rugged-nimbus-611.internal>
 <CAGXu5jKfjKPuGO98S5XwVSuOcimLtZD6Y9WRQ9pvdBa16TQyFw@mail.gmail.com>
 <20160809000015.GA9866@ircssh.c.rugged-nimbus-611.internal>
 <CAGXu5jKJTqb25vE_TyRiv1X3tg-dU3OLXh+FxPfcBhxmQoOZ=A@mail.gmail.com>
 <57B0F768.8000307@digikod.net>
 <20160815030952.GC31242@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="0VUOPQi8IDCAB49wlODo7sN4ApHLD9wsp"
Cc: Kees Cook <keescook@chromium.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Reshetova, Elena" <elena.reshetova@intel.com>
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160815030952.GC31242@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0VUOPQi8IDCAB49wlODo7sN4ApHLD9wsp
Content-Type: multipart/mixed; boundary="XNCOStDjja1r03tsItccSTfHtRHdk66EF"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Sargun Dhillon <sargun@sargun.me>
Cc: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <alexei.starovoitov@gmail.com>,
 Daniel Borkmann <daniel@iogearbox.net>,
 linux-security-module <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>,
 "Reshetova, Elena" <elena.reshetova@intel.com>
Message-ID: <57B1A081.9030209@digikod.net>
Subject: Re: [RFC 0/4] RFC: Add Checmate, BPF-driven minor LSM
References: <20160804071116.GA19098@ircssh.c.rugged-nimbus-611.internal>
 <CAGXu5jKfjKPuGO98S5XwVSuOcimLtZD6Y9WRQ9pvdBa16TQyFw@mail.gmail.com>
 <20160809000015.GA9866@ircssh.c.rugged-nimbus-611.internal>
 <CAGXu5jKJTqb25vE_TyRiv1X3tg-dU3OLXh+FxPfcBhxmQoOZ=A@mail.gmail.com>
 <57B0F768.8000307@digikod.net>
 <20160815030952.GC31242@ircssh.c.rugged-nimbus-611.internal>
In-Reply-To: <20160815030952.GC31242@ircssh.c.rugged-nimbus-611.internal>

--XNCOStDjja1r03tsItccSTfHtRHdk66EF
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 15/08/2016 05:09, Sargun Dhillon wrote:
> On Mon, Aug 15, 2016 at 12:57:44AM +0200, Micka=C3=ABl Sala=C3=BCn wrot=
e:
>> Our approaches have some common points (i.e. use eBPF in an LSM, stack=
ed=20
>> filters like seccomp) but I'm focused on a kind of unprivileged LSM (i=
=2Ee. no=20
>> CAP_SYS_ADMIN), to make standalone sandboxes, which brings more constr=
aints=20
>> (e.g. no use of unsafe functions like bpf_probe_read(), take care of p=
rivacy,=20
>> SUID exec, stable ABI=E2=80=A6). However, I don't want to handle resou=
rce limits,=20
>> which should be the job of cgroups.
>>
> Kind of. Sometimes describing these resource limits is difficult. For e=
xample, I=20
> have a customer who is trying to restrict containers from burning up al=
l the=20
> ephemeral ports on the machine. In this, they have an incredibly elabor=
ate chain=20
> of wiring to prevent a given container from connecting to the same (pro=
to,=20
> destip, destport) more than 1000 times.
>=20
> I'm unsure of how you'd model that in a cgroup.=20

This looks like a Netfilter rule. Have you tried applying this limitation=
 with the connlimit module?


>=20
>> For now, I'm focusing on file-system access control which is one of th=
e more=20
>> complex system to properly filter. I also plan to support basic networ=
k access=20
>> control.
>>
>> What you are trying to accomplish seems more related to a Netfilter ex=
tension=20
>> (something like ipset but with eBPF maybe?).
>>
> I don't only want to do network access control, I also want to write to=
 the=20
> value once it's copied into kernel space. There are lot of benefits of =
doing=20
> this at the syscall level, but the two primary ones are performance, an=
d=20
> capability.=20
>=20
> One of the biggest complaints with our current approach to filtering & =
load=20
> balancing (iptables) is that it hides information. When people connect =
through=20
> the load balancer, they want to find out who they connected to, and wit=
hout some=20
> high application-level mechanism, this isn't possible. On the other han=
d, if we=20
> just rewrite the destination address in the connect hook, we can pretty=
 easily
> allow them to do getpeername.

What exactly is not doable with Netfilter (e.g. REDIRECT or TPROXY)?


>=20
> I'm curious about your filesystem access limiter. Do you have a way to =
make it so
> that a given container can only write, say, 100mb of data to disk?=20

It's a filesystem access control. It doesn't deal with quota and is not f=
ocused on container but process hierarchies (which is more generic).

What is not doable with a quota mount option? It may be more appropriate =
to enhance the VFS (or overlayfs) to apply this kind of limitation, if ne=
eded.


--XNCOStDjja1r03tsItccSTfHtRHdk66EF--

--0VUOPQi8IDCAB49wlODo7sN4ApHLD9wsp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXsaCNAAoJECLe/t9zvWqVGg8IAJ+C8DzVjeBJDm4rgD6BVFha
6V29tMnouofgoS1lnYwp5Mmuco8PTMg929HYBTD9zB4Wk7ALht+JrP+hu/n9gWII
BsM1DxwFk+YtgUsV3RP4ADcpha93FCbYVAYijQCOTA3cB2t5JrOKRBffeD9lVIFd
JPM155CCJRkLFX0booWO1F9nCodwRHp5ovoXMOgY/6sA7EhxqoRR17bJ/qPHJWUS
R20ceKQpK1Z8d3DixYY5+EZXzvkU9QHVKwsZeXb4MLEQGE2z2VeqMQo3QgVIyHoG
hPVIIFWQGYEdySNVNW0UZ/snan8Hu36IYYWzzEiXruVwdLJGlZK2Z0jGpYxNcOg=
=EKC8
-----END PGP SIGNATURE-----

--0VUOPQi8IDCAB49wlODo7sN4ApHLD9wsp--
