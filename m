From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] x86: fix and improve cmpxchg_double{,_local}()
Date: Tue, 03 Jan 2012 16:41:30 +0100
Message-ID: <1325605290.2320.76.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F01F12A020000780006A19B@nat28.tlf.novell.com>
	 <1325602830.2320.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325603714.2320.73.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com,
	Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1325603714.2320.73.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 03 janvier 2012 =C3=A0 16:15 +0100, Eric Dumazet a =C3=A9crit =
:

> Very old it seems...
>=20
> arch/x86/lib/atomic64_cx8_32.S
>=20
> all "jxx 1b" are wrong if a LOCK_PREFIX is included after the 1: labe=
l
>=20
> 1:
> 	inst1
> 	LOCK_PREFIX
> 	cmpxchg8b (%ebp)
> 	jne 1b  / jumps to beginning of LOCK_PREFIX, inst1 is not replayed
>=20
>=20
>=20
>=20

A possible fix would be to not use "1" label in LOCK_PREFIX macro,
but 672 magic value.

Not sure if we can use a local label in a macro ?

 arch/x86/include/asm/alternative-asm.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/alternative-asm.h b/arch/x86/include/=
asm/alternative-asm.h
index 091508b..952bd01 100644
--- a/arch/x86/include/asm/alternative-asm.h
+++ b/arch/x86/include/asm/alternative-asm.h
@@ -4,10 +4,10 @@
=20
 #ifdef CONFIG_SMP
 	.macro LOCK_PREFIX
-1:	lock
+672:	lock
 	.section .smp_locks,"a"
 	.balign 4
-	.long 1b - .
+	.long 672b - .
 	.previous
 	.endm
 #else
