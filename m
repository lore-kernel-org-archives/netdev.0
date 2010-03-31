From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-2.6 PATCH] bonding: fix broken multicast with round-robin
 mode
Date: Wed, 31 Mar 2010 23:23:06 +0200
Message-ID: <1270070586.2593.6.camel@edumazet-laptop>
References: <1270026517.2103.9.camel@edumazet-laptop>
	 <m2x7b667921003310749v5c8b6e62g7339eff24a51e6d8@mail.gmail.com>
	 <1270048448.2103.28.camel@edumazet-laptop>
	 <20100331.140055.246389406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andy@greyhouse.net, netdev@vger.kernel.org, lhh@redhat.com,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:36578 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758129Ab0CaVX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 17:23:28 -0400
Received: by bwz1 with SMTP id 1so415060bwz.21
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 14:23:26 -0700 (PDT)
In-Reply-To: <20100331.140055.246389406.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 31 mars 2010 =C3=A0 14:00 -0700, David Miller a =C3=A9crit =
:

> Funny how going back in time gives us better diagnostic messages from
> the compiler :-)
>=20
> FWIW I also didn't get the warning, and that was with gcc-4.5 built
> from the gcc trunk just the other day.
>=20
> I suspect this is to do with a change to what warnings get enabled by
> default with the -W options we put in the cflags rather than gcc
> losing the ability to detect this case.

  x86_64-unknown-linux-gcc -Wp,-MD,drivers/net/bonding/.bond_main.o.d
-nostdinc
-isystem /data/x86-64/lib/gcc/x86_64-unknown-linux/4.1.2/include
-I/data/src/linux-2.6/arch/x86/include -Iinclude  -include
include/generated/autoconf.h -D__KERNEL__ -Wall -Wundef
-Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common
-Werror-implicit-function-declaration -Wno-format-security
-fno-delete-null-pointer-checks -O2 -m64 -mno-red-zone -mcmodel=3Dkerne=
l
-funit-at-a-time -maccumulate-outgoing-args -DCONFIG_AS_CFI=3D1
-DCONFIG_AS_CFI_SIGNAL_FRAME=3D1 -pipe -Wno-sign-compare
-fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow
-fno-stack-protector -fno-omit-frame-pointer -fno-optimize-sibling-call=
s
-g -pg -Wdeclaration-after-statement -Wno-pointer-sign
-D"KBUILD_STR(s)=3D#s" -D"KBUILD_BASENAME=3DKBUILD_STR(bond_main)"
-D"KBUILD_MODNAME=3DKBUILD_STR(bonding)"  -c -o
drivers/net/bonding/.tmp_bond_main.o drivers/net/bonding/bond_main.c
drivers/net/bonding/bond_main.c: In function =E2=80=98bond_xmit_roundro=
bin=E2=80=99:
drivers/net/bonding/bond_main.c:4159: warning: comparison is always
false due to limited range of data type


while with gcc-4.4.2 (native compiler, no warning displayed)

 gcc -Wp,-MD,drivers/net/bonding/.bond_main.o.d  -nostdinc
-isystem /usr/lib/gcc/x86_64-linux-gnu/4.4.3/include
-I/usr/src/git/linux-2.6/arch/x86/include -Iinclude  -include
include/generated/autoconf.h -D__KERNEL__ -Wall -Wundef
-Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common
-Werror-implicit-function-declaration -Wno-format-security
-fno-delete-null-pointer-checks -O2 -m64 -mtune=3Dgeneric -mno-red-zone
-mcmodel=3Dkernel -funit-at-a-time -maccumulate-outgoing-args
-DCONFIG_AS_CFI=3D1 -DCONFIG_AS_CFI_SIGNAL_FRAME=3D1 -pipe -Wno-sign-co=
mpare
-fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow
-Wframe-larger-than=3D1024 -fno-stack-protector -fno-omit-frame-pointer
-fno-optimize-sibling-calls -g -Wdeclaration-after-statement
-Wno-pointer-sign -fno-strict-overflow -fno-dwarf2-cfi-asm
-fconserve-stack   -D"KBUILD_STR(s)=3D#s"
-D"KBUILD_BASENAME=3DKBUILD_STR(bond_main)"
-D"KBUILD_MODNAME=3DKBUILD_STR(bond_main)"  -c -o
drivers/net/bonding/.tmp_bond_main.o drivers/net/bonding/bond_main.c


New compiler got these new options :  -Wframe-larger-than=3D1024
-fno-strict-overflow -fno-dwarf2-cfi-asm -fconserve-stack



