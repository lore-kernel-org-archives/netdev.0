From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating
 master'ssettings toslaves
Date: Mon, 11 Aug 2003 13:43:27 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F37D5BF.8000702@pobox.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com> <200308111720.38472.shmulik.hen@intel.com> <1060612481.1034.15.camel@jzny.localdomain> <200308111925.38278.shmulik.hen@intel.com> <3F37C7C3.7070807@pobox.com> <3F37D2ED.B4B9223C@thalesatm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: shmulik.hen@intel.com, hadi@cyberus.ca,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Laurent DENIEL <laurent.deniel@thalesatm.com>
In-Reply-To: <3F37D2ED.B4B9223C@thalesatm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Laurent DENIEL wrote:
> Jeff Garzik a =E9crit :
>=20
>>The answer is, like life, it's a balance.
>>
>>As a general rule, we do prefer to move all code possible out of the
>>Linux kernel.  We have even created "initramfs", which for 2.7, will be
>>used as a vehicle to move code from the kernel to userspace, that
>>previously had to be in the kernel only because it was a task that "had
>>to be performed at boot time".
>>
>>However, one must consider
>>(1) does moving code to userspace create any security holes?
>>(2) does moving code to userspace dramatically increase the number of
>>context switches?
>>(3) does moving code to userspace violate some atomicity that being
>>inside the kernel guarantees?
>=20
>=20
> You forgot one important aspect :=20
>=20
>   (4) does moving code to userspace break compatibility (or behavior)=20
>       with user land applications (or systems)

I agree... assuming these userland interfaces are fairly standard and=20
widely deployed.


> What can one do if say, kernel 2.[4|5] switches the NIC in 10 mseconds=20
> while kernel 2.7 with user land daemon switches in a few seconds ?=20
> nothing but stay with the previous version or fork the driver developme=
nt ;-(

This is a silly example.  If that happens in practice, then that is a=20
bug in the configuration of the userland daemon, or a bug in the=20
kernel<->userland ABI.


> But I agree that it is interesting to do some stuff at user land, and i=
f=20
> the bonding had an option to disable the automatic failover policy,=20
> this could be implemented with trigger towards user land application th=
at=20
> could use an ioctl call to switch to the appropriate NIC according to=20
> the user lan configuration ...

Remember, ioctls are bad.  :)  Unix design mistake.


> But the fast and simple failover policy shall remain in kernel code.

I would not make such absolute predictions, especially about policy :)

	Jeff
