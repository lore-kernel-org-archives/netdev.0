From: Javier Herrero <jherrero@hvsistemas.es>
Subject: Re: [PATCH 1/1] netdev: DM9000: Added typecasting to supress some
 warnings on Blackfin
Date: Mon, 13 Oct 2008 11:28:23 +0200
Message-ID: <48F314B7.3020708@hvsistemas.es>
References: <1223889009-31336-1-git-send-email-cooloney@kernel.org> <20081013091725.GG31627@trinity.fluff.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bryan Wu <cooloney@kernel.org>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from zm1.veloxia.com ([213.149.227.2]:35460 "HELO zm1.veloxia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1759846AbYJMJfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 05:35:07 -0400
In-Reply-To: <20081013091725.GG31627@trinity.fluff.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Bryan,

So it seems that we must correct that in other place?

Regards,

Javier

Ben Dooks escribi=F3:
> On Mon, Oct 13, 2008 at 05:10:09PM +0800, Bryan Wu wrote:
>> From: Javier Herrero <jherrero@hvsistemas.es>
>
> No, your arch definitions of writesb and co are wrong if they
> are not taking 'void __iomem *' arguments.
> =20
>> Signed-off-by: Javier Herrero <jherrero@hvsistemas.es>
>> Signed-off-by: Bryan Wu <cooloney@kernel.org>
>> ---
>>  drivers/net/dm9000.c |   12 ++++++------
>>  1 files changed, 6 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
>> index f42c23f..c4737ca 100644
>> --- a/drivers/net/dm9000.c
>> +++ b/drivers/net/dm9000.c
>> @@ -188,35 +188,35 @@ iow(board_info_t * db, int reg, int value)
>> =20
>>  static void dm9000_outblk_8bit(void __iomem *reg, void *data, int c=
ount)
>>  {
>> -	writesb(reg, data, count);
>> +	writesb((int)reg, data, count);
>>  }
>> =20
>>  static void dm9000_outblk_16bit(void __iomem *reg, void *data, int =
count)
>>  {
>> -	writesw(reg, data, (count+1) >> 1);
>> +	writesw((int)reg, data, (count+1) >> 1);
>>  }
>> =20
>>  static void dm9000_outblk_32bit(void __iomem *reg, void *data, int =
count)
>>  {
>> -	writesl(reg, data, (count+3) >> 2);
>> +	writesl((int)reg, data, (count+3) >> 2);
>>  }
>> =20
>>  /* input block from chip to memory */
>> =20
>>  static void dm9000_inblk_8bit(void __iomem *reg, void *data, int co=
unt)
>>  {
>> -	readsb(reg, data, count);
>> +	readsb((int)reg, data, count);
>>  }
>> =20
>> =20
>>  static void dm9000_inblk_16bit(void __iomem *reg, void *data, int c=
ount)
>>  {
>> -	readsw(reg, data, (count+1) >> 1);
>> +	readsw((int)reg, data, (count+1) >> 1);
>>  }
>> =20
>>  static void dm9000_inblk_32bit(void __iomem *reg, void *data, int c=
ount)
>>  {
>> -	readsl(reg, data, (count+3) >> 2);
>> +	readsl((int)reg, data, (count+3) >> 2);
>>  }
>> =20
>>  /* dump block from chip to null */
>> --=20
>> 1.5.6
>

--=20
-----------------------------------------------------------------------=
-
Javier Herrero                            EMAIL: jherrero@hvsistemas.co=
m
HV Sistemas S.L.                          PHONE:         +34 949 336 80=
6
Los Charcones, 17A                        FAX:           +34 949 336 79=
2
19170 El Casar - Guadalajara - Spain      WEB: http://www.hvsistemas.co=
m

