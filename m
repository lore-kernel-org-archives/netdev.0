From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v2] net: introduce helper macro for_each_cmsghdr
Date: Thu, 11 Dec 2014 09:05:59 +0800
Message-ID: <5488EDF7.7070001@cn.fujitsu.com>
References: <5487DBD9.1010908@cn.fujitsu.com> <20141210.134804.1383875260695429574.davem@davemloft.net> <20141210.144430.1749715282635917425.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141210.144430.1749715282635917425.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,
On 12/11/2014 03:44 AM, David Miller wrote:

> From: David Miller <davem@davemloft.net>
> Date: Wed, 10 Dec 2014 13:48:04 -0500 (EST)
>=20
>> From: Gu Zheng <guz.fnst@cn.fujitsu.com>
>> Date: Wed, 10 Dec 2014 13:36:25 +0800
>>
>>> Introduce helper macro for_each_cmsghdr as a wrapper of the enumera=
ting
>>> cmsghdr from msghdr, just cleanup.=20
>>>
>>> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
>>
>> Applied, thanks.
>=20
> This breaks the build, I'm reverting.

I'm very sorry.

>=20
> You cannot use your new macros in
> Documentation/networking/timestamping/txtimestamp.c, that is a
> userland program and the header you are adding your helper to is not
> available to userspace.

IMO, the user-land programs need to be build with the matched headers s=
eparately.
I split the kernel codes and the user-land programs, build and install =
the kernel first,
and then build the user-land ones.=20

>=20
> This also means you didn't sufficiently test the build of your
> changes.

To be honest, I do the test as I mentioned above.

Thanks,
Gu

>=20
> Documentation/networking/timestamping/timestamping.c: In function =A1=
printpacket=A2:
> Documentation/networking/timestamping/timestamping.c:172:2: warning: =
implicit declaration of function =A1for_each_cmsghdr=A2 [-Wimplicit-fun=
ction-declaration]
> Documentation/networking/timestamping/timestamping.c:172:30: error: e=
xpected =A1;=A2 before =A1{=A2 token
> Documentation/networking/timestamping/timestamping.c:161:18: warning:=
 unused variable =A1ts=A2 [-Wunused-variable]
> Documentation/networking/timestamping/timestamping.c:160:17: warning:=
 unused variable =A1tv=A2 [-Wunused-variable]
> make[3]: *** [Documentation/networking/timestamping/timestamping] Err=
or 1
> make[3]: *** Waiting for unfinished jobs....
> Documentation/networking/timestamping/txtimestamp.c: In function =A1_=
_recv_errmsg_cmsg=A2:
> Documentation/networking/timestamping/txtimestamp.c:187:2: warning: i=
mplicit declaration of function =A1for_each_cmsghdr=A2 [-Wimplicit-func=
tion-declaration]
> Documentation/networking/timestamping/txtimestamp.c:187:19: error: =A1=
cmsg=A2 undeclared (first use in this function)
> Documentation/networking/timestamping/txtimestamp.c:187:19: note: eac=
h undeclared identifier is reported only once for each function it appe=
ars in
> Documentation/networking/timestamping/txtimestamp.c:187:30: error: ex=
pected =A1;=A2 before =A1{=A2 token
> Documentation/networking/timestamping/txtimestamp.c:185:18: warning: =
unused variable =A1cm=A2 [-Wunused-variable]
> Documentation/networking/timestamping/txtimestamp.c:184:27: warning: =
unused variable =A1tss=A2 [-Wunused-variable]
> Documentation/networking/timestamping/txtimestamp.c:183:28: warning: =
unused variable =A1serr=A2 [-Wunused-variable]
> Documentation/networking/timestamping/txtimestamp.c: At top level:
> Documentation/networking/timestamping/txtimestamp.c:123:13: warning: =
=A1print_timestamp=A2 defined but not used [-Wunused-function]
> Documentation/networking/timestamping/txtimestamp.c:159:13: warning: =
=A1print_pktinfo=A2 defined but not used [-Wunused-function]
>=20
