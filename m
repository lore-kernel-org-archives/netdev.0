From: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
Subject: Re: net: mv643xx: interface does not transmit after some time
Date: Thu, 11 Feb 2016 11:38:07 -0300
Message-ID: <CAAEAJfBFNEPRd+AaKpRAh6sKFJ=trO+mAD_DAAj3dzhAbbreqg@mail.gmail.com>
References: <E4F9E0D0-9DA8-4E33-9F89-B49E47F11CE0@schloeter.net>
	<20160206183414.GD17218@lunn.ch>
	<20160206231935.GA30734@jirafa.cyrius.com>
	<2ACB3A0B-DD51-43C1-A56E-E7C175645554@schloeter.net>
	<20160207203545.GB29107@lunn.ch>
	<A21B89D4-5826-4F97-A1C9-E62E5B724082@schloeter.net>
	<312E318A-CAE1-45B1-AB13-EA147B48E315@schloeter.net>
	<A6128DBC-59DB-4231-A08D-B84C1D8C26CC@schloeter.net>
	<20160210225717.GD14610@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Martin Michlmayr <tbm@cyrius.com>,
	Linux ARM Kernel <linux-arm-kernel@lists.infradead.org>,
	philipp@familie-kirchhofer.de,
	Karl Beldan <karl.beldan@rivierawaves.com>,
	netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Andrew Lunn <andrew@lunn.ch>,
	=?UTF-8?Q?Thomas_Schl=C3=B6ter?= <thomas@schloeter.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36153 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520AbcBKOiI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 09:38:08 -0500
Received: by mail-wm0-f49.google.com with SMTP id p63so76076977wmp.1
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 06:38:08 -0800 (PST)
In-Reply-To: <20160210225717.GD14610@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(let's expand the Cc a bit)

On 10 February 2016 at 19:57, Andrew Lunn <andrew@lunn.ch> wrote:
> On Wed, Feb 10, 2016 at 07:40:54PM +0100, Thomas Schl=C3=B6ter wrote:
>>
>> > Am 08.02.2016 um 19:49 schrieb Thomas Schl=C3=B6ter <thomas@schloe=
ter.net>:
>> >
>> >
>> >> Am 07.02.2016 um 22:07 schrieb Thomas Schl=C3=B6ter <thomas@schlo=
eter.net>:
>> >>
>> >> Am 07.02.2016 um 21:35 schrieb Andrew Lunn <andrew@lunn.ch>:
>> >>>
>> >>>>> FWIW, we had a similar bug report in Debian recently:
>> >>>>> https://lists.debian.org/debian-arm/2016/01/msg00098.html
>> >>>
>> >>> Hi Thomas
>> >>>
>> >>> I this thread, Ian Campbell mentions a patch. Please could you t=
ry
>> >>> that patch and see if it fixes your problem.
>> >>>
>> >>> Thanks
>> >>>   Andrew
>> >>
>> >> Hi Andrew,
>> >>
>> >> I just applied the patch and the NAS is now running it. I???ll tr=
y to crash it tonight and keep you informed whether it worked.
>> >>
>> >> Thanks
>> >>    Thomas
>> >
>> > Hi Andrew,
>> >
>> > the patch did not fix the problem. After 1.2 GiB RX and 950 MiB TX=
, the interface crashed again.
>> >
>> > Now I switched off RX/TX offload just to make sure we are talking =
about the same problem. If we are, the interface should be stable witho=
ut offload, right?
>> >
>> >     Thomas
>>
>> Okay, so I have installed ethtool and switched off all offload featu=
res available. Now the NAS is running rock solid for two days. I backed=
 up my Mac using Time Machine / netatalk (450 GiB transferred) and some=
 Linux machines via NFS (100 GiB total) without a problem.
>>
>> How much code is used for mv643xx offload functionality?
>> Is it possible to debug things in the driver and figure out what hap=
pens during the crash?
>> Is the hardware offload interface proprietary or reverse engineered =
or is it a well known API that can be analyzed?
>
> Hi Thomas
>
> Ezequiel Garcia probably knows this part of the driver and hardware
> the best...
>

The TCP segmentation offload (TSO) implemented in this driver is
mostly a software thing.

I'm CCing Karl and Philipp, who have fixed subtle issues in the TSO
path, and may be able to help figure this one out.

--=20
Ezequiel Garc=C3=ADa, VanguardiaSur
www.vanguardiasur.com.ar
