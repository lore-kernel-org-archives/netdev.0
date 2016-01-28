From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: UBSAN: Undefined behaviour in net/ipv4/fib_trie.c:1397:22 and
 UBSAN: Undefined behaviour in ./arch/x86/include/asm/atomic.h:156:2
Date: Thu, 28 Jan 2016 09:15:09 -0800
Message-ID: <CAKgT0UeU7BC6XQ9VqwUWYX1SdDk7kGKXdrEgfkkSiDS0i5-3gw@mail.gmail.com>
References: <56A7CCD6.9030105@gmx.de>
	<1453844178.11327.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>,
	Alexander Duyck <alexander.duyck@redhat.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453844178.11327.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2016 at 1:36 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Tue, 2016-01-26 at 20:45 +0100, Toralf F=C3=B6rster wrote:
>> at a 32 nbit KVM image of a Gentoo Linux runniogn v4.5-rc1 - attache=
d is /var/log/messages
>>
>
> Jan 26 20:40:04 n22kvm-clone kernel: =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Jan 26 20:40:04 n22kvm-clone kernel: UBSAN: Undefined behaviour in ne=
t/ipv4/fib_trie.c:1397:22
> Jan 26 20:40:04 n22kvm-clone kernel: shift exponent 32 is too large f=
or 32-bit type 'long unsigned int'
> Jan 26 20:40:04 n22kvm-clone kernel: CPU: 1 PID: 2050 Comm: dhcpcd No=
t tainted 4.5.0-rc1 #1
> Jan 26 20:40:04 n22kvm-clone kernel: Hardware name: QEMU Standard PC =
(i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04=
/01/2014
>
> Thanks for the report.
>
> CC netdev and Alexander
>
> Commit 79e5ad2ceb006
> ("fib_trie: Remove leaf_info ")

I looked over the line in question, it is an issue where we are doing
the shift and then sanitizing for the undefined result after the fact.
I'll see about submitting a patch to address this.

- Alex
