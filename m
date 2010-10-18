From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes [was: TIPC 2.0 and TIPC_SUB_SERVICE]
Date: Mon, 18 Oct 2010 16:42:33 -0400
Message-ID: <AANLkTimKbOreV4Fuyw3TbCrk9aa5yBZQSuRbo3Vdx=Q1@mail.gmail.com>
References: <20100927163823.GD2834@integratech.com.ar>
	<29C1DC0826876849BDD9F1C67ABA2943090B67EC@ala-mail09.corp.ad.wrs.com>
	<20100929153805.GG2834@integratech.com.ar>
	<29C1DC0826876849BDD9F1C67ABA29430914AC18@ala-mail09.corp.ad.wrs.com>
	<20101001150034.GS8781@llucax.com.ar>
	<0434463FDA60A94FA978ACA44617682DEE843EDD79@EUSAACMS0702.eamcs.ericsson.se>
	<20101001162346.GV8781@llucax.com.ar>
	<4CA69F18.7000005@amln.net>
	<0434463FDA60A94FA978ACA44617682DEE8446A03B@EUSAACMS0702.eamcs.ericsson.se>
	<20101018150422.GV8781@llucax.com.ar>
	<20101018184628.GX8781@llucax.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Maloy <jon.maloy@ericsson.com>, davem@redhat.com,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Leandro Lucarella <luca@llucax.com.ar>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101018184628.GX8781@llucax.com.ar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 18, 2010 at 2:46 PM, Leandro Lucarella <luca@llucax.com.ar>=
 wrote:
> Leandro Lucarella, el 18 de octubre a las 12:04 me escribiste:
>> This means D can't be used to write code that uses TIPC if you targe=
t
>> kernels >=3D 2.6.35 (unless they write their own bindings, or at lea=
st use
>> a custom TIPC_SUB_SERVICE constant). I could change the TIPC_SUB_SER=
VICE
>> value, but then people using older kernels will be screwed. Another
>> option is to use the version statement (kind of like C's #ifdef):
>>
>> =A0 =A0 =A0 version (TIPC_2_0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 const TIPC_SUB_SERVICE =3D 0x00;
>> =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 const TIPC_SUB_SERVICE =3D 0x02;
>
> I keep finding problems with this change. Another, no D-related, prob=
lem
> with this change is old code could be silently (and very subtly) brok=
en
> if they check for TIPC_SUB_SERVICE as a flag with something like:
>
> =A0 =A0 =A0 =A0if (s.filter & TIPC_SUB_SERVICE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* do something */
>
> Because TIPC_SUB_SERVICE has changed its semantics, not just its valu=
e,
> and the new value (0x00) will give you always 0 in that test. This on=
e
> is really tricky, because the application code will fail silently, th=
ere
> will be no dmesg indication of a failure, nor the connection to the
> topology service be closed. You might get a compiler warning if you'r=
e
> lucky.

If you have access to the user space code in question, you can just
switch behaviour semantics based on the results of a uname call, knowin=
g
that this change was included in versions since approx last Feb.  There
is also /proc/version which can be parsed manually if you prefer.

If you have kernel code/modules, you can do the same/similar things wit=
h
the KERNEL_VERSION and its support macros.

In either case, you don't have to restrict yourself to information that=
 is
specific to and/or exported just from TIPC itself.

Hope that helps,
Paul.

>
> --
> Leandro Lucarella (AKA luca) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
http://llucax.com.ar/
> ---------------------------------------------------------------------=
-
> GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145 =A0104C 949E BFB6 5F5A 8D=
05)
> ---------------------------------------------------------------------=
-
> Novocaine for the soul
> you better give me something
> to fill the hole
> before I sputter out
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
