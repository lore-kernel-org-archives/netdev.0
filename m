From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH] net: pfifo_fast - use ffs(x)-1 instead of array lookup
Date: Tue, 13 Mar 2012 13:37:25 -0700
Message-ID: <CANP3RGe6zQzsuvZ=qpcWFou6EY99HhWq0ekf6UkfqKCvj+eiRA@mail.gmail.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E9E@saturn3.aculab.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6EA1@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44798 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823Ab2CMUh2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 16:37:28 -0400
Received: by eekc41 with SMTP id c41so621771eek.19
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 13:37:26 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6EA1@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

but a 16-bit constant will be better than a 32-bit one on 16-bit platfo=
rms

On Tue, Mar 13, 2012 at 9:55 AM, David Laight <David.Laight@aculab.com>=
 wrote:
>
>> > + =C2=A0 /* For i in 0..7 returns {-1, 0, 1, 0, 2, 0, 1, 0}[i] */
>> > + =C2=A0 return ((26468 >> (i+i)) & 3) - 1;
>>
>> That expression doesn't seem quite right to me ...
>> =C2=A0 =C2=A0 =C2=A0 return (int)(0x12131210 >> (i * 4)) & 3) - 1;
>> probably does what is wanted.
>
> Hmmm... I'm going blind - I read that as 'i+1' not 'i+i'.
> But using 'i * 4' and putting the constant in base 16
> make the code rather less obscure.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0David
>
>



--=20
Maciej A. =C5=BBenczykowski
Kernel Networking Developer @ Google
1600 Amphitheatre Parkway, Mountain View, CA 94043
tel: +1 (650) 253-0062
