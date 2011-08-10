From: Wang Shaoyan <stufever@gmail.com>
Subject: Re: [PATCH] gianfar: reduce stack usage in gianfar_ethtool.c
Date: Wed, 10 Aug 2011 10:20:07 +0800
Message-ID: <CANxBZFrMgFdedyq2SoY3neoHbQVKjDfXjNVfMyOZcTApQuLUEA@mail.gmail.com>
References: <1312907945-1982-1-git-send-email-wangshaoyan.pt@taobao.com>
	<1312908784.2371.53.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, Wang Shaoyan <wangshaoyan.pt@taobao.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:50207 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006Ab1HJCUH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 22:20:07 -0400
In-Reply-To: <1312908784.2371.53.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/8/10 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mercredi 10 ao=FBt 2011 =E0 00:39 +0800, stufever@gmail.com a =E9c=
rit :
>> From: Wang Shaoyan <wangshaoyan.pt@taobao.com>
>>
>> =A0 drivers/net/gianfar_ethtool.c:765: warning: the frame size of 20=
48 bytes is larger than 1024 bytes
>>
>> Signed-off-by: Wang Shaoyan <wangshaoyan.pt@taobao.com>
>> ---
>> =A0drivers/net/gianfar_ethtool.c | =A0 20 +++++++++++++++++---
>> =A01 files changed, 17 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_eth=
tool.c
>> index 6e35069..134fe1b 100644
>> --- a/drivers/net/gianfar_ethtool.c
>> +++ b/drivers/net/gianfar_ethtool.c
>> @@ -686,10 +686,21 @@ static int gfar_ethflow_to_filer_table(struct =
gfar_private *priv, u64 ethflow, u
>> =A0{
>> =A0 =A0 =A0 unsigned int last_rule_idx =3D priv->cur_filer_idx;
>> =A0 =A0 =A0 unsigned int cmp_rqfpr;
>> - =A0 =A0 unsigned int local_rqfpr[MAX_FILER_IDX + 1];
>> - =A0 =A0 unsigned int local_rqfcr[MAX_FILER_IDX + 1];
>> + =A0 =A0 unsigned int *local_rqfpr;
>> + =A0 =A0 unsigned int *local_rqfcr;
>> =A0 =A0 =A0 int i =3D 0x0, k =3D 0x0;
>> =A0 =A0 =A0 int j =3D MAX_FILER_IDX, l =3D 0x0;
>> + =A0 =A0 int ret =3D 1;
>> +
>> + =A0 =A0 local_rqfpr =3D kmalloc(sizeof(unsigned int) * (MAX_FILER_=
IDX + 1),
>> + =A0 =A0 =A0 =A0 =A0 =A0 GFP_KERNEL);
>> + =A0 =A0 local_rqfcr =3D kmalloc(sizeof(unsigned int) * (MAX_FILER_=
IDX + 1),
>> + =A0 =A0 =A0 =A0 =A0 =A0 GFP_KERNEL);
>> + =A0 =A0 if (!local_rqfpr || !local_rqfcr) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 pr_err("Out of memory\n");
>
> =A0 =A0 =A0 =A0Please remove this pr_err(), kmalloc() will complain a=
lready.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 got err;
>> + =A0 =A0 }
>>
>> =A0 =A0 =A0 switch (class) {
>> =A0 =A0 =A0 case TCP_V4_FLOW:
>> @@ -765,7 +776,10 @@ static int gfar_ethflow_to_filer_table(struct g=
far_private *priv, u64 ethflow, u
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->cur_filer_idx =3D priv->cur_filer_=
idx - 1;
>> =A0 =A0 =A0 }
>>
>> - =A0 =A0 return 1;
>> +err:
>> + =A0 =A0 kfree(local_rqfcr);
>> + =A0 =A0 kfree(local_rqfpr);
>> + =A0 =A0 return ret;
>> =A0}
>>
>

Thanks, I will do it

> You should now track all "return 0;" done in this function to make su=
re
> no memory leak is added by your patch.
>
>
>
>



--=20
Wang Shaoyan
