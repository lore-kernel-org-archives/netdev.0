From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/3] vxlan: silence one build warning
Date: Sat, 26 Oct 2013 07:48:19 -0700
Message-ID: <20131026074819.6a5f4e24@samsung-9>
References: <1382687360-27794-1-git-send-email-zwu.kernel@gmail.com>
	<20131025084134.6cfa153a@samsung-9>
	<CAEH94Lia4VVU6Vnn_7DhOHo4yhR-tsMPu7biMCeSMgQPvkQrug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	linux-kernel mlist <linux-kernel@vger.kernel.org>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEH94Lia4VVU6Vnn_7DhOHo4yhR-tsMPu7biMCeSMgQPvkQrug@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 26 Oct 2013 15:06:04 +0800
Zhi Yong Wu <zwu.kernel@gmail.com> wrote:

> On Fri, Oct 25, 2013 at 11:41 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > On Fri, 25 Oct 2013 15:49:18 +0800
> > Zhi Yong Wu <zwu.kernel@gmail.com> wrote:
> >
> >> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> >>
> >> drivers/net/vxlan.c: In function =E2=80=98vxlan_sock_add=E2=80=99:
> >> drivers/net/vxlan.c:2298:11: warning: =E2=80=98sock=E2=80=99 may b=
e used uninitialized in this function [-Wmaybe-uninitialized]
> >> drivers/net/vxlan.c:2275:17: note: =E2=80=98sock=E2=80=99 was decl=
ared here
> >>   LD      drivers/net/built-in.o
> >>
> >> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> >> ---
> >>  drivers/net/vxlan.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> >> index 2ef5b62..e15f1af 100644
> >> --- a/drivers/net/vxlan.c
> >> +++ b/drivers/net/vxlan.c
> >> @@ -2272,7 +2272,7 @@ static struct vxlan_sock *vxlan_socket_creat=
e(struct net *net, __be16 port,
> >>  {
> >>       struct vxlan_net *vn =3D net_generic(net, vxlan_net_id);
> >>       struct vxlan_sock *vs;
> >> -     struct socket *sock;
> >> +     struct socket *sock =3D NULL;
> >>       struct sock *sk;
> >>       int rc =3D 0;
> >>       unsigned int h;
> >
> > This only happens with certain versions of Gcc which have buggy dep=
endency
> > analysis. It doesn't happen with Gcc 4.7, think it only shows up in=
 4.4.
> > I would rather not fix the warning this way since it risks masking =
later bugs if this code ever changes.
> Gcc version is 4.7.2 on my box, this warning took palce.
> # gcc -v
> Using built-in specs.
> COLLECT_GCC=3Dgcc
> ...
> gcc version 4.7.2 20120921 (Red Hat 4.7.2-2) (GCC)
>=20
>=20

I dont see it on Debian 7.
$ gcc -v
Using built-in specs.
COLLECT_GCC=3D/usr/bin/gcc-4.7.real
COLLECT_LTO_WRAPPER=3D/usr/lib/gcc/x86_64-linux-gnu/4.7/lto-wrapper
Target: x86_64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion=3D'Debian 4.7.2-=
5' --with-bugurl=3Dfile:///usr/share/doc/gcc-4.7/README.Bugs --enable-l=
anguages=3Dc,c++,go,fortran,objc,obj-c++ --prefix=3D/usr --program-suff=
ix=3D-4.7 --enable-shared --enable-linker-build-id --with-system-zlib -=
-libexecdir=3D/usr/lib --without-included-gettext --enable-threads=3Dpo=
six --with-gxx-include-dir=3D/usr/include/c++/4.7 --libdir=3D/usr/lib -=
-enable-nls --with-sysroot=3D/ --enable-clocale=3Dgnu --enable-libstdcx=
x-debug --enable-libstdcxx-time=3Dyes --enable-gnu-unique-object --enab=
le-plugin --enable-objc-gc --with-arch-32=3Di586 --with-tune=3Dgeneric =
--enable-checking=3Drelease --build=3Dx86_64-linux-gnu --host=3Dx86_64-=
linux-gnu --target=3Dx86_64-linux-gnu
Thread model: posix
gcc version 4.7.2 (Debian 4.7.2-5)
