From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCH linux-next] hisax: disable build for big-endian arm
Date: Fri, 22 Nov 2013 08:45:04 +0100
Message-ID: <528F0B80.9020900@linux-pingi.de>
References: <1385077794-17022-1-git-send-email-vincent.stehle@laposte.net> <s5hzjowhp2l.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?VmluY2VudCBTdGVobMOp?= <vincent.stehle@laposte.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <s5hzjowhp2l.wl%tiwai@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 22.11.2013 08:29, schrieb Takashi Iwai:
> At Fri, 22 Nov 2013 00:49:54 +0100,
> Vincent Stehl=C3=A9 wrote:
>>
>> Teles PCI and HFC PCI-bus refuse to build on big-endian ARM; disable=
 them in
>> Kconfig.
>>
>> Signed-off-by: Vincent Stehl=C3=A9 <vincent.stehle@laposte.net>
>> Cc: Karsten Keil <isdn@linux-pingi.de>
>> ---
>>
>> Hi,
>>
>> This can be seen on e.g. linux next-20131121 with arm allyesconfig.
>>
>> Best regards,
>>
>> V.
>>
>>  drivers/isdn/hisax/Kconfig | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/isdn/hisax/Kconfig b/drivers/isdn/hisax/Kconfig
>> index d9edcc9..53dbb75 100644
>> --- a/drivers/isdn/hisax/Kconfig
>> +++ b/drivers/isdn/hisax/Kconfig
>> @@ -109,7 +109,7 @@ config HISAX_16_3
>> =20
>>  config HISAX_TELESPCI
>>  	bool "Teles PCI"
>> -	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (=
MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
>> +	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (=
MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) ||=
 (ARM && !CPU_LITTLE_ENDIAN)))
>=20
> Isn't it a bit better to exclude CPU_LITTLE_ENDIAN globally?
>=20
> 	depends on PCI && CPU_LITTLE_ENDIAN && (BROKEN || !(SPARC || PPC || =
PARISC || M68K || MIPS || FRV || XTENSA || ARM))
>=20
> Or maybe just
>=20
> 	depends on PCI && (X86 || BROKEN)
>=20
> (Alpha?  Can anyone test? :)

I never got this card so it was never in my tests, if I remember
correctely  somebody had it running with Alpha before 2000.
And yes I'm fine if we simplify this mess to only X86.

Karsten
