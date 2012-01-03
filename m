From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH] x86: fix and improve cmpxchg_double{,_local}()
Date: Tue, 03 Jan 2012 16:08:44 +0000
Message-ID: <4F03361C020000780006A3A5@nat28.tlf.novell.com>
References: <4F01F12A020000780006A19B@nat28.tlf.novell.com>
 <1325602830.2320.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1325603714.2320.73.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1325605290.2320.76.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <mingo@elte.hu>, <tglx@linutronix.de>,
	"Christoph Lameter" <cl@linux.com>, <linux-kernel@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>, <hpa@zytor.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1325605290.2320.76.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 03.01.12 at 16:41, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le mardi 03 janvier 2012 =C3=A0 16:15 +0100, Eric Dumazet a =C3=A9cri=
t :
>=20
>> Very old it seems...
>>=20
>> arch/x86/lib/atomic64_cx8_32.S
>>=20
>> all "jxx 1b" are wrong if a LOCK_PREFIX is included after the 1: lab=
el
>>=20
>> 1:
>> 	inst1
>> 	LOCK_PREFIX
>> 	cmpxchg8b (%ebp)
>> 	jne 1b  / jumps to beginning of LOCK_PREFIX, inst1 is not replayed
>>=20
>>=20
>>=20
>>=20
>=20
> A possible fix would be to not use "1" label in LOCK_PREFIX macro,
> but 672 magic value.
>=20
> Not sure if we can use a local label in a macro ?

"1" and "672" are both local labels, so both are okay. As long as there=
's
no other (colliding) use of 672 anywhere, that would seem to be the
preferred fix (feel free to put my ack on the patch when you formally
submit it).

Jan

>  arch/x86/include/asm/alternative-asm.h |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/arch/x86/include/asm/alternative-asm.h=20
> b/arch/x86/include/asm/alternative-asm.h
> index 091508b..952bd01 100644
> --- a/arch/x86/include/asm/alternative-asm.h
> +++ b/arch/x86/include/asm/alternative-asm.h
> @@ -4,10 +4,10 @@
> =20
>  #ifdef CONFIG_SMP
>  	.macro LOCK_PREFIX
> -1:	lock
> +672:	lock
>  	.section .smp_locks,"a"
>  	.balign 4
> -	.long 1b - .
> +	.long 672b - .
>  	.previous
>  	.endm
>  #else
