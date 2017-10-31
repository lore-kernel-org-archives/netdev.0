From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute2 compile and linking errors on Fedora 19
Date: Tue, 31 Oct 2017 22:10:06 +0100
Message-ID: <20171031221006.13cf9be8@shemminger-XPS-13-9360>
References: <CAM_iQpV07bZscuS5g6nZJ1Ko_RYVv7QyxVtga_Ky5EnbxXhCug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Phil Sutter <phil@nwl.cc>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:52241 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750928AbdJaVKb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 17:10:31 -0400
Received: by mail-lf0-f67.google.com with SMTP id b190so358769lfg.9
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 14:10:31 -0700 (PDT)
In-Reply-To: <CAM_iQpV07bZscuS5g6nZJ1Ko_RYVv7QyxVtga_Ky5EnbxXhCug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 10:58:46 -0700
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> Hi,
>=20
> The latest iproute2 in git fails with the following compile error on
> Fedora 19 (I know it is very old!):
>=20
> xfrm_state.c: In function =E2=80=98usage=E2=80=99:
> xfrm_state.c:104:36: error: =E2=80=98IPPROTO_MH=E2=80=99 undeclared (firs=
t use in this function)
>   fprintf(stderr, "%s", strxf_proto(IPPROTO_MH));
>                                     ^
> xfrm_state.c:104:36: note: each undeclared identifier is reported only
> once for each function it appears in
> make[1]: *** [xfrm_state.o] Error 1
> make[1]: *** Waiting for unfinished jobs....
> xfrm_policy.c: In function =E2=80=98usage=E2=80=99:
> xfrm_policy.c:77:36: error: =E2=80=98IPPROTO_MH=E2=80=99 undeclared (firs=
t use in this function)
>   fprintf(stderr, "%s", strxf_proto(IPPROTO_MH));
>                                     ^
> xfrm_policy.c:77:36: note: each undeclared identifier is reported only
> once for each function it appears in
> make[1]: *** [xfrm_policy.o] Error 1
> ipxfrm.c: In function =E2=80=98xfrm_selector_print=E2=80=99:
> ipxfrm.c:479:7: error: =E2=80=98IPPROTO_MH=E2=80=99 undeclared (first use=
 in this function)
>   case IPPROTO_MH:
>        ^
> ipxfrm.c:479:7: note: each undeclared identifier is reported only once
> for each function it appears in
> ipxfrm.c: In function =E2=80=98xfrm_selector_upspec_parse=E2=80=99:
> ipxfrm.c:1345:8: error: =E2=80=98IPPROTO_MH=E2=80=99 undeclared (first us=
e in this function)
>    case IPPROTO_MH:
>         ^
>=20
>=20
> After fixing it manually by including <xtables.h> in each of these C
> files, the compilation is okay but now it fails with linking errors:
>=20
>=20
> xfrm_state.o: In function `xfrm_state_modify.constprop.3':
> xfrm_state.c:(.text+0x2337): undefined reference to `strlcpy'
> ipnetns.o: In function `netns_identify_pid':
> ipnetns.c:(.text+0x10fd): undefined reference to `strlcpy'
> ipxfrm.o: In function `xfrm_state_info_print':
> ipxfrm.c:(.text+0x1a2a): undefined reference to `strlcat'
> ipxfrm.c:(.text+0x1a3c): undefined reference to `strlcat'
> ipxfrm.c:(.text+0x1eff): undefined reference to `strlcat'
> ipxfrm.o: In function `xfrm_policy_info_print':
> ipxfrm.c:(.text+0x2010): undefined reference to `strlcat'
> ipxfrm.c:(.text+0x2022): undefined reference to `strlcat'
> iproute_lwtunnel.o: In function `parse_encap_seg6':
> iproute_lwtunnel.c:(.text+0xa4f): undefined reference to `strlcpy'
> ipvrf.o: In function `vrf_switch':
> ipvrf.c:(.text+0x7be): undefined reference to `strlcpy'
> ipvrf.o: In function `vrf_identify.constprop.2':
> ipvrf.c:(.text+0xdbd): undefined reference to `strlcpy'
> ../lib/libutil.a(bpf.o): In function `bpf_find_mntpt.constprop.10':
> bpf.c:(.text+0x64e): undefined reference to `strlcpy'
> ../lib/libutil.a(bpf.o): In function `bpf_get_work_dir':
> bpf.c:(.text+0x99f): undefined reference to `strlcpy'
> ../lib/libutil.a(fs.o):fs.c:(.text+0x3df): more undefined references
> to `strlcpy' follow
> collect2: error: ld returned 1 exit status
> make[1]: *** [ip] Error 1
> make[1]: Leaving directory `/root/iproute2/ip'
> make: *** [all] Error 2
>=20
> This is the GCC on Fedora 19:
>=20
> # gcc -v
> Using built-in specs.
> COLLECT_GCC=3D/bin/gcc
> COLLECT_LTO_WRAPPER=3D/usr/libexec/gcc/x86_64-redhat-linux/4.8.3/lto-wrap=
per
> Target: x86_64-redhat-linux
> Configured with: ../configure --prefix=3D/usr --mandir=3D/usr/share/man
> --infodir=3D/usr/share/info
> --with-bugurl=3Dhttp://bugzilla.redhat.com/bugzilla --enable-bootstrap
> --enable-shared --enable-threads=3Dposix --enable-checking=3Drelease
> --with-system-zlib --enable-__cxa_atexit
> --disable-libunwind-exceptions --enable-gnu-unique-object
> --enable-linker-build-id --with-linker-hash-style=3Dgnu
> --enable-languages=3Dc,c++,objc,obj-c++,java,fortran,ada,go,lto
> --enable-plugin --enable-initfini-array --enable-java-awt=3Dgtk
> --disable-dssi --with-java-home=3D/usr/lib/jvm/java-1.5.0-gcj-1.5.0.0/jre
> --enable-libgcj-multifile --enable-java-maintainer-mode
> --with-ecj-jar=3D/usr/share/java/eclipse-ecj.jar
> --disable-libjava-multilib
> --with-isl=3D/builddir/build/BUILD/gcc-4.8.3-20140911/obj-x86_64-redhat-l=
inux/isl-install
> --with-cloog=3D/builddir/build/BUILD/gcc-4.8.3-20140911/obj-x86_64-redhat=
-linux/cloog-install
> --with-tune=3Dgeneric --with-arch_32=3Di686 --build=3Dx86_64-redhat-linux
> Thread model: posix
> gcc version 4.8.3 20140911 (Red Hat 4.8.3-7) (GCC)
>=20
>=20
> I don't know if people still care about it. I think iproute2 should
> compile with older kernels/distros. I can dig this deeper when I have
> time.
>=20
>=20
> Thanks.

IPPROTO_MH comes from include/uapi/linux/in6.h
Maybe it is trying to use old kernel headers from libc.
