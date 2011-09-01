From: Wang Sheng-Hui <shhuiw@gmail.com>
Subject: Re: [PATCH] dev_ioctl should return -EINVAL for unknown ioctl instead
 of -ENOTTY
Date: Fri, 02 Sep 2011 06:00:48 +0800
Message-ID: <4E600090.5030505@gmail.com>
References: <4E5F9C14.1040108@gmail.com> <1314891670.2733.12.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:49952 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932082Ab1IAWA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 18:00:59 -0400
In-Reply-To: <1314891670.2733.12.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011=E5=B9=B409=E6=9C=8801=E6=97=A5 23:41, Ben Hutchings wrote:
> On Thu, 2011-09-01 at 22:52 +0800, Wang Sheng-Hui wrote:
>> The patch is against 3.1-rc3.
>>
>> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
>> ---
>>  net/core/dev.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 17d67b5..de6033c 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -5092,7 +5092,7 @@ int dev_ioctl(struct net *net, unsigned int cm=
d, void __user *arg)
>>  		/* Take care of Wireless Extensions */
>>  		if (cmd >=3D SIOCIWFIRST && cmd <=3D SIOCIWLAST)
>>  			return wext_handle_ioctl(net, &ifr, cmd, arg);
>> -		return -ENOTTY;
>> +		return -EINVAL;
>>  	}
>>  }
>> =20
>=20
> Whereas, Linus Torvalds wrote in
> <BANLkTin=3DPTbTwBR2s+owMLy+GmKigeoYvg@mail.gmail.com>:
> [...]
>> The correct error code for "I don't understand this ioctl" is ENOTTY=
=2E
>> The naming may be odd, but you should think of that error value as a
>> "unrecognized ioctl number, you're feeding me random numbers that I
>> don't understand and I assume for historical reasons that you tried =
to
>> do some tty operation on me".
> [...]
>=20
> (Not that we are consistent about using ENOTTY in networking now.)
>=20
> Ben.
>=20

Got it. Thanks.
