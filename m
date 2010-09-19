From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: How about the order of Network stack initialize
Date: Sat, 18 Sep 2010 17:53:49 -0700
Message-ID: <20100918175349.a6773dca.rdunlap@xenotime.net>
References: <201009160906134537778@gmail.com>
	<20100917141940.f2e5ff20.rdunlap@xenotime.net>
	<201009190848041099641@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "ly" <ly@yahoo.com.cn>, "linux-net" <linux-net@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>
To: "Huangqiang Zhou" <linuxkernel.xqiang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([72.52.115.56]:52500 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753752Ab0ISAxv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Sep 2010 20:53:51 -0400
Received: from chimera.site ([173.50.240.230]) by xenotime.net for <netdev@vger.kernel.org>; Sat, 18 Sep 2010 17:53:49 -0700
In-Reply-To: <201009190848041099641@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 19 Sep 2010 08:48:09 +0800 Huangqiang Zhou wrote:

> Hi:
> yes, i have found the answer.
>=20
> "please refer to the macro definition INITCALLS in the header file
> include/asm-generic/vmlinux.lds.h -- many definitions are moved to
> this file now." --- by Randy Dunlap=20
>=20

That answer was
=46rom:	Tony Wan <visual2me@gmail.com>


>=20
> 2010-09-19=20
>=20
>=20
>=20
> Huangqiang Zhou=20
>=20
>=20
>=20
> =E5=8F=91=E4=BB=B6=E4=BA=BA=EF=BC=9A Randy Dunlap=20
> =E5=8F=91=E9=80=81=E6=97=B6=E9=97=B4=EF=BC=9A 2010-09-18  05:19:50=20
> =E6=94=B6=E4=BB=B6=E4=BA=BA=EF=BC=9A Huangqiang Zhou=20
> =E6=8A=84=E9=80=81=EF=BC=9A ly; linux-net; netdev=20
> =E4=B8=BB=E9=A2=98=EF=BC=9A Re: How about the order of Network stack =
initialize=20
> =20
> On Thu, 16 Sep 2010 09:06:16 +0800 Huangqiang Zhou wrote:
> > Hi all=EF=BC=9A
> >=20
> > I have a question about the order of  network stack initialize.
> >=20
> > From some books it says the order is as below:
> > 1.core_initcall: sock_init
> > 2.fs_initcall: inet_init
> > 3.subsys_initcall: net_dev_init
> > 4.device_initcall: device init
> >=20
> > in the source code of linux2.6.18:
> > #define core_initcall(fn) __define_initcall("1",fn)
> > #define postcore_initcall(fn) __define_initcall("2",fn)
> > #define arch_initcall(fn) __define_initcall("3",fn)
> > #define subsys_initcall(fn) __define_initcall("4",fn)
> > #define fs_initcall(fn) __define_initcall("5",fn)
> > #define device_initcall(fn) __define_initcall("6",fn)
> > #define late_initcall(fn) __define_initcall("7",fn)
> >=20
> > obviously:
> > macro                 section
> > core_initcall <--> .initcall1.init=20
> > fs_initcall <--> .initcall5.init
> > subsys_initcall <--> .initcall4.init
> > device_intcall <--> .initcall6.init
> >=20
> > Some also says=EF=BC=9A
> > =E2=80=9CEvery child is to determine the sequence between sections,=
 the first call. Initcall1 init.=20
> >  The function pointer, again. Initcall2 init. Call the function poi=
nter, etc. And in each section=20
> >  of the function pointer is associated with links to order, is unce=
rtain =E2=80=9D
> >=20
> >  As the above says, the order should be: core_initcall->subsys_init=
call->fs_initcall->device_intcall
> >=20
> > So which one is really correct?
> >=20
> > 2010-09-15=20
> > Huangqiang Zhou
> Hi,
> BTW, did you find out anything from your previous posting's answers?
> http://marc.info/?l=3Dlinux-net&m=3D128443018603483&w=3D2
> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your c=
ode ***


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your cod=
e ***
