From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: iproute2 compile and linking errors on Fedora 19
Date: Tue, 31 Oct 2017 10:58:46 -0700
Message-ID: <CAM_iQpV07bZscuS5g6nZJ1Ko_RYVv7QyxVtga_Ky5EnbxXhCug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:52070 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932532AbdJaR7H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 13:59:07 -0400
Received: by mail-pg0-f41.google.com with SMTP id p9so15302111pgc.8
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 10:59:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The latest iproute2 in git fails with the following compile error on
Fedora 19 (I know it is very old!):

xfrm_state.c: In function =E2=80=98usage=E2=80=99:
xfrm_state.c:104:36: error: =E2=80=98IPPROTO_MH=E2=80=99 undeclared (first =
use in this function)
  fprintf(stderr, "%s", strxf_proto(IPPROTO_MH));
                                    ^
xfrm_state.c:104:36: note: each undeclared identifier is reported only
once for each function it appears in
make[1]: *** [xfrm_state.o] Error 1
make[1]: *** Waiting for unfinished jobs....
xfrm_policy.c: In function =E2=80=98usage=E2=80=99:
xfrm_policy.c:77:36: error: =E2=80=98IPPROTO_MH=E2=80=99 undeclared (first =
use in this function)
  fprintf(stderr, "%s", strxf_proto(IPPROTO_MH));
                                    ^
xfrm_policy.c:77:36: note: each undeclared identifier is reported only
once for each function it appears in
make[1]: *** [xfrm_policy.o] Error 1
ipxfrm.c: In function =E2=80=98xfrm_selector_print=E2=80=99:
ipxfrm.c:479:7: error: =E2=80=98IPPROTO_MH=E2=80=99 undeclared (first use i=
n this function)
  case IPPROTO_MH:
       ^
ipxfrm.c:479:7: note: each undeclared identifier is reported only once
for each function it appears in
ipxfrm.c: In function =E2=80=98xfrm_selector_upspec_parse=E2=80=99:
ipxfrm.c:1345:8: error: =E2=80=98IPPROTO_MH=E2=80=99 undeclared (first use =
in this function)
   case IPPROTO_MH:
        ^


After fixing it manually by including <xtables.h> in each of these C
files, the compilation is okay but now it fails with linking errors:


xfrm_state.o: In function `xfrm_state_modify.constprop.3':
xfrm_state.c:(.text+0x2337): undefined reference to `strlcpy'
ipnetns.o: In function `netns_identify_pid':
ipnetns.c:(.text+0x10fd): undefined reference to `strlcpy'
ipxfrm.o: In function `xfrm_state_info_print':
ipxfrm.c:(.text+0x1a2a): undefined reference to `strlcat'
ipxfrm.c:(.text+0x1a3c): undefined reference to `strlcat'
ipxfrm.c:(.text+0x1eff): undefined reference to `strlcat'
ipxfrm.o: In function `xfrm_policy_info_print':
ipxfrm.c:(.text+0x2010): undefined reference to `strlcat'
ipxfrm.c:(.text+0x2022): undefined reference to `strlcat'
iproute_lwtunnel.o: In function `parse_encap_seg6':
iproute_lwtunnel.c:(.text+0xa4f): undefined reference to `strlcpy'
ipvrf.o: In function `vrf_switch':
ipvrf.c:(.text+0x7be): undefined reference to `strlcpy'
ipvrf.o: In function `vrf_identify.constprop.2':
ipvrf.c:(.text+0xdbd): undefined reference to `strlcpy'
../lib/libutil.a(bpf.o): In function `bpf_find_mntpt.constprop.10':
bpf.c:(.text+0x64e): undefined reference to `strlcpy'
../lib/libutil.a(bpf.o): In function `bpf_get_work_dir':
bpf.c:(.text+0x99f): undefined reference to `strlcpy'
../lib/libutil.a(fs.o):fs.c:(.text+0x3df): more undefined references
to `strlcpy' follow
collect2: error: ld returned 1 exit status
make[1]: *** [ip] Error 1
make[1]: Leaving directory `/root/iproute2/ip'
make: *** [all] Error 2

This is the GCC on Fedora 19:

# gcc -v
Using built-in specs.
COLLECT_GCC=3D/bin/gcc
COLLECT_LTO_WRAPPER=3D/usr/libexec/gcc/x86_64-redhat-linux/4.8.3/lto-wrappe=
r
Target: x86_64-redhat-linux
Configured with: ../configure --prefix=3D/usr --mandir=3D/usr/share/man
--infodir=3D/usr/share/info
--with-bugurl=3Dhttp://bugzilla.redhat.com/bugzilla --enable-bootstrap
--enable-shared --enable-threads=3Dposix --enable-checking=3Drelease
--with-system-zlib --enable-__cxa_atexit
--disable-libunwind-exceptions --enable-gnu-unique-object
--enable-linker-build-id --with-linker-hash-style=3Dgnu
--enable-languages=3Dc,c++,objc,obj-c++,java,fortran,ada,go,lto
--enable-plugin --enable-initfini-array --enable-java-awt=3Dgtk
--disable-dssi --with-java-home=3D/usr/lib/jvm/java-1.5.0-gcj-1.5.0.0/jre
--enable-libgcj-multifile --enable-java-maintainer-mode
--with-ecj-jar=3D/usr/share/java/eclipse-ecj.jar
--disable-libjava-multilib
--with-isl=3D/builddir/build/BUILD/gcc-4.8.3-20140911/obj-x86_64-redhat-lin=
ux/isl-install
--with-cloog=3D/builddir/build/BUILD/gcc-4.8.3-20140911/obj-x86_64-redhat-l=
inux/cloog-install
--with-tune=3Dgeneric --with-arch_32=3Di686 --build=3Dx86_64-redhat-linux
Thread model: posix
gcc version 4.8.3 20140911 (Red Hat 4.8.3-7) (GCC)


I don't know if people still care about it. I think iproute2 should
compile with older kernels/distros. I can dig this deeper when I have
time.


Thanks.
