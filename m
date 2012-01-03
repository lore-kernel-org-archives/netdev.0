From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] x86: fix and improve cmpxchg_double{,_local}()
Date: Tue, 03 Jan 2012 17:13:38 +0100
Message-ID: <1325607218.2320.89.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F01F12A020000780006A19B@nat28.tlf.novell.com>
	 <1325602830.2320.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325603714.2320.73.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325605290.2320.76.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F03361C020000780006A3A5@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mingo@elte.hu, tglx@linutronix.de,
	Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, hpa@zytor.com
To: Jan Beulich <JBeulich@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F03361C020000780006A3A5@nat28.tlf.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 03 janvier 2012 =C3=A0 16:08 +0000, Jan Beulich a =C3=A9crit :

> "1" and "672" are both local labels, so both are okay. As long as the=
re's
> no other (colliding) use of 672 anywhere, that would seem to be the
> preferred fix (feel free to put my ack on the patch when you formally
> submit it).

I was referring the use of a label local to the macro itself, with
restricted scope.

following psudi code would trigger an asm error :

	.macro FOO
	.local_label 1
1:	lock
        .section .smp_locks,"a"
        .balign 4
        .long 1b - .
        .previous
	.endm


	FOO
	jne 1b
