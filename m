From: "Bryan Wu" <cooloney@kernel.org>
Subject: Re: [PATCH 1/1] netdev: DM9000: Added typecasting to supress some warnings on Blackfin
Date: Mon, 13 Oct 2008 17:52:00 +0800
Message-ID: <386072610810130252s52c11423r69851740975ff517@mail.gmail.com>
References: <1223889009-31336-1-git-send-email-cooloney@kernel.org>
	 <20081013091725.GG31627@trinity.fluff.org>
	 <48F314B7.3020708@hvsistemas.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Javier Herrero" <jherrero@hvsistemas.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.191]:44145 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762108AbYJMJwD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 05:52:03 -0400
Received: by rn-out-0910.google.com with SMTP id k40so772586rnd.17
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2008 02:52:00 -0700 (PDT)
In-Reply-To: <48F314B7.3020708@hvsistemas.es>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2008 at 5:28 PM, Javier Herrero <jherrero@hvsistemas.es=
> wrote:
> Hi, Bryan,
>
> So it seems that we must correct that in other place?
>

Yes, we need to check the I/O read_write functions.

-Bryan

> Regards,
>
> Javier
>
> Ben Dooks escribi=F3:
>>
>> On Mon, Oct 13, 2008 at 05:10:09PM +0800, Bryan Wu wrote:
>>>
>>> From: Javier Herrero <jherrero@hvsistemas.es>
>>
>> No, your arch definitions of writesb and co are wrong if they
>> are not taking 'void __iomem *' arguments.
>>
>>>
>>> Signed-off-by: Javier Herrero <jherrero@hvsistemas.es>
>>> Signed-off-by: Bryan Wu <cooloney@kernel.org>
>>> ---
>>>  drivers/net/dm9000.c |   12 ++++++------
>>>  1 files changed, 6 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
>>> index f42c23f..c4737ca 100644
>>> --- a/drivers/net/dm9000.c
>>> +++ b/drivers/net/dm9000.c
>>> @@ -188,35 +188,35 @@ iow(board_info_t * db, int reg, int value)
>>>   static void dm9000_outblk_8bit(void __iomem *reg, void *data, int
>>> count)
>>>  {
>>> -       writesb(reg, data, count);
>>> +       writesb((int)reg, data, count);
>>>  }
>>>   static void dm9000_outblk_16bit(void __iomem *reg, void *data, in=
t
>>> count)
>>>  {
>>> -       writesw(reg, data, (count+1) >> 1);
>>> +       writesw((int)reg, data, (count+1) >> 1);
>>>  }
>>>   static void dm9000_outblk_32bit(void __iomem *reg, void *data, in=
t
>>> count)
>>>  {
>>> -       writesl(reg, data, (count+3) >> 2);
>>> +       writesl((int)reg, data, (count+3) >> 2);
>>>  }
>>>   /* input block from chip to memory */
>>>   static void dm9000_inblk_8bit(void __iomem *reg, void *data, int =
count)
>>>  {
>>> -       readsb(reg, data, count);
>>> +       readsb((int)reg, data, count);
>>>  }
>>>    static void dm9000_inblk_16bit(void __iomem *reg, void *data, in=
t
>>> count)
>>>  {
>>> -       readsw(reg, data, (count+1) >> 1);
>>> +       readsw((int)reg, data, (count+1) >> 1);
>>>  }
>>>   static void dm9000_inblk_32bit(void __iomem *reg, void *data, int
>>> count)
>>>  {
>>> -       readsl(reg, data, (count+3) >> 2);
>>> +       readsl((int)reg, data, (count+3) >> 2);
>>>  }
>>>   /* dump block from chip to null */
>>> --
>>> 1.5.6
>>
>
> --
> ---------------------------------------------------------------------=
---
> Javier Herrero                            EMAIL: jherrero@hvsistemas.=
com
> HV Sistemas S.L.                          PHONE:         +34 949 336 =
806
> Los Charcones, 17A                        FAX:           +34 949 336 =
792
> 19170 El Casar - Guadalajara - Spain      WEB: http://www.hvsistemas.=
com
>
>
