From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 11:46:11 +0100
Message-ID: <yw1xhaq1p9qk.fsf@unicorn.mansr.com>
References: <506E1762.3010601@gmail.com>
	<CANLjY-no-L9=LRCvCetC5XCHicOoSWOfRZmUd7itAiUHWBhAyw@mail.gmail.com>
	<CAG5Tg6Wuybruc31x1eh6mFafsg=7cOgYLgpZUBuJUo75ap3osQ@mail.gmail.com>
	<506E3E58.80703@gmail.com>
	<CAG5Tg6V0Vj9HTy3=AU-q+Qa3DuJs6R1Kw+3uOWU_jOGfkgyXzw@mail.gmail.com>
	<20121005071216.GD4625@n2100.arm.linux.org.uk>
	<CAG5Tg6VciuxJ=k+fatzLugcehF54mGNOLHpUwdMX99oCnAVg8Q@mail.gmail.com>
	<20121005082439.GF4625@n2100.arm.linux.org.uk>
	<506ED18C.3010009@gmail.com>
	<20121005140556.GQ4625@n2100.arm.linux.org.uk>
	<506EEFBB.3060705@gmail.com> <507619FA.6080001@jonmasters.org>
	<yw1xtxu1pwtv.fsf@unicorn.mansr.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7038@saturn3.aculab.com>
	<yw1xpq4ppcju.fsf@unicorn.mansr.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B703B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	"Jon Masters" <jonathan@jonmasters.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([78.86.181.103]:34571 "EHLO
	unicorn.mansr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753050Ab2JKKqM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 06:46:12 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B703B@saturn3.aculab.com>
	(David Laight's message of "Thu, 11 Oct 2012 11:16:16 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"David Laight" <David.Laight@ACULAB.COM> writes:

>> > It might be enough to use __attribute__((aligned(2))) on some stru=
cture
>> > members (actually does 'ldm' need 8 byte alignment?? - in which ca=
se
>> > aligned(4) is enough).
>>=20
>> The aligned attribute can only increase alignment.
>
> Not true.
> If you have:
>
> struct foo {
>     short   a;
>     int     b __attribute__((aligned(2)));
>     short   c;
> };
>
> You'll find sizeof (struct foo) is 8, and that, on arm/sparc etc,
> gcc will generate 2 16bit accesses (and shifts) for foo.b;

That is not what the manual says.  Quoting:

     When used on a struct, or struct member, the `aligned' attribute
     can only increase the alignment

My gcc agrees with the manual:

$ cat foo.c
struct foo {
    short a;
    int b __attribute__((aligned(2)));
    short c;
};

int foo(struct foo *f)
{
    return f->b;
}
$ arm-unknown-linux-gnueabi-gcc-4.7.2 -O2 -o- -S foo.c
        .text
        .align  2
        .global foo
        .type   foo, %function
foo:
        ldr     r0, [r0, #4]
        bx      lr

(compiler output edited for clarity)

This clearly says the 'b' member resides at an offset of 4 bytes into
the struct.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
