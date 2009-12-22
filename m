From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel Panics in the network stack
Date: Tue, 22 Dec 2009 12:32:23 +0100
Message-ID: <4B30AE47.7040703@gmail.com>
References: <4B309AED.7080601@gmail.com> <1261480105.29570.15.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kevin Constantine <kevin.constantine@gmail.com>,
	netdev@vger.kernel.org,
	linux kernel <linux-kernel@vger.kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752825AbZLVLcn@vger.kernel.org>
In-Reply-To: <1261480105.29570.15.camel@pc1117.cambridge.arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 22/12/2009 12:08, Catalin Marinas a =C3=A9crit :
> On Tue, 2009-12-22 at 10:09 +0000, Eric Dumazet wrote:
>> __switch_to:
>>
>> ...
>>         ldm r4, {r4, r5, r6, r7, r8, r9, sl, fp, sp, pc}
>=20
> It looks to me like it is possible to get an interrupt after SP was
> loaded but before PC, the stack could be corrupted and PC would be
> loaded with garbage. One instance of your oops messages looks like PC
> corruption but the other may be caused by something else. What ARM CP=
U
> are you using?

I saw other very strange corruptions (registers R6 & R7) as well, on Ke=
vin supplied traces.

>=20
> I'm cc'ing Russell as well, it's strange that we haven't got any issu=
e
> with this so far.

Oh well, it seems I CC'ed Rusty Russel instead :)

>=20
> You could try #undef'ing __ARCH_WANT_INTERRUPTS_ON_CTXSW in
> arch/arm/include/asm/system.h as a sanity check for your aborts.
>=20

Kevin uses linuxstamp card, from open circuits :

http://www.opencircuits.com/Linuxstamp

It's a AT91RM9200 processor (Arm9 with MMU, 180MHz )

Thanks
