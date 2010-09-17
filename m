From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: How about the order of Network stack initialize
Date: Fri, 17 Sep 2010 14:19:40 -0700
Message-ID: <20100917141940.f2e5ff20.rdunlap@xenotime.net>
References: <201009160906134537778@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "ly" <ly@yahoo.com.cn>, "linux-net" <linux-net@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>
To: "Huangqiang Zhou" <linuxkernel.xqiang@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <201009160906134537778@gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2010 09:06:16 +0800 Huangqiang Zhou wrote:

> Hi all=EF=BC=9A
>=20
> I have a question about the order of  network stack initialize.
>=20
> From some books it says the order is as below:
> 1.core_initcall: sock_init
> 2.fs_initcall: inet_init
> 3.subsys_initcall: net_dev_init
> 4.device_initcall: device init
>=20
> in the source code of linux2.6.18:
> #define core_initcall(fn) __define_initcall("1",fn)
> #define postcore_initcall(fn) __define_initcall("2",fn)
> #define arch_initcall(fn) __define_initcall("3",fn)
> #define subsys_initcall(fn) __define_initcall("4",fn)
> #define fs_initcall(fn) __define_initcall("5",fn)
> #define device_initcall(fn) __define_initcall("6",fn)
> #define late_initcall(fn) __define_initcall("7",fn)
>=20
> obviously:
> macro                 section
> core_initcall <--> .initcall1.init=20
> fs_initcall <--> .initcall5.init
> subsys_initcall <--> .initcall4.init
> device_intcall <--> .initcall6.init
>=20
> Some also says=EF=BC=9A
> =E2=80=9CEvery child is to determine the sequence between sections, t=
he first call. Initcall1 init.=20
>  The function pointer, again. Initcall2 init. Call the function point=
er, etc. And in each section=20
>  of the function pointer is associated with links to order, is uncert=
ain =E2=80=9D
>=20
>  As the above says, the order should be: core_initcall->subsys_initca=
ll->fs_initcall->device_intcall
>=20
> So which one is really correct?
>=20
> 2010-09-15=20
> Huangqiang Zhou

Hi,

BTW, did you find out anything from your previous posting's answers?

http://marc.info/?l=3Dlinux-net&m=3D128443018603483&w=3D2

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your cod=
e ***
