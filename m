From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: alignment faults in 3.6
Date: Thu, 11 Oct 2012 09:21:35 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7038@saturn3.aculab.com>
References: <506E1762.3010601@gmail.com><CANLjY-no-L9=LRCvCetC5XCHicOoSWOfRZmUd7itAiUHWBhAyw@mail.gmail.com><CAG5Tg6Wuybruc31x1eh6mFafsg=7cOgYLgpZUBuJUo75ap3osQ@mail.gmail.com><506E3E58.80703@gmail.com><CAG5Tg6V0Vj9HTy3=AU-q+Qa3DuJs6R1Kw+3uOWU_jOGfkgyXzw@mail.gmail.com><20121005071216.GD4625@n2100.arm.linux.org.uk><CAG5Tg6VciuxJ=k+fatzLugcehF54mGNOLHpUwdMX99oCnAVg8Q@mail.gmail.com><20121005082439.GF4625@n2100.arm.linux.org.uk><506ED18C.3010009@gmail.com><20121005140556.GQ4625@n2100.arm.linux.org.uk><506EEFBB.3060705@gmail.com> <507619FA.6080001@jonmasters.org> <yw1xtxu1pwtv.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
To: =?Windows-1252?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	"Jon Masters" <jonathan@jonmasters.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37030 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753793Ab2JKIdR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 04:33:17 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14799-02 for <netdev@vger.kernel.org>;
 Thu, 11 Oct 2012 09:33:13 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <yw1xtxu1pwtv.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.o=
rg] On Behalf Of M=E5ns Rullg=E5rd
> Sent: 11 October 2012 03:27
> To: Jon Masters
> Cc: linux-arm-kernel@lists.infradead.org; netdev@vger.kernel.org
> Subject: Re: alignment faults in 3.6
>=20
> Jon Masters <jonathan@jonmasters.org> writes:
>=20
> > Hi everyone,
> >
> > On 10/05/2012 10:33 AM, Rob Herring wrote:
> >> On 10/05/2012 09:05 AM, Russell King - ARM Linux wrote:
> >>> On Fri, Oct 05, 2012 at 07:24:44AM -0500, Rob Herring wrote:
> >>>> On 10/05/2012 03:24 AM, Russell King - ARM Linux wrote:
> >>>>> Does it matter?  I'm just relaying the argument against adding =
__packed
> >>>>> which was used before we were forced (by the networking folk) t=
o implement
> >>>>> the alignment fault handler.
> >>>>
> >>>> It doesn't really matter what will be accepted or not as adding =
__packed
> >>>> to struct iphdr doesn't fix the problem anyway.=20
=2E..
> There are exactly two possible solutions:
>=20
> 1. Change the networking code so those structs are always aligned.  T=
his
>    might not be (easily) possible.
> 2. Mark the structs __packed and fix any typecasts like the ones seen=
 in
>    this thread.  This will have an adverse effect in cases where the
>    structs are in fact aligned.
>=20
> Both solutions lie squarely in the networking code.  It's time to
> involve that list, or we'll never get anywhere.

It might be enough to use __attribute__((aligned(2))) on some structure
members (actually does 'ldm' need 8 byte alignment?? - in which case
aligned(4) is enough).

One on my bugbears is hardware that will once receive ethernet frames
onto a 4n boundary - it needs to be 4n+2. two bytes of 'junk' will do.

	David
