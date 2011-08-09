From: Wang Shaoyan <stufever@gmail.com>
Subject: Re: [PATCH] gianfar: reduce stack usage in gianfar_ethtool.c
Date: Wed, 10 Aug 2011 00:02:04 +0800
Message-ID: <CANxBZFoApuc2GabXnx-1SVLsbhFWw5=b1dbSFqiE-nAcb=5sPA@mail.gmail.com>
References: <1312903103-1734-1-git-send-email-wangshaoyan.pt@taobao.com>
	<1312904624.2371.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, Wang Shaoyan <wangshaoyan.pt@taobao.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312904624.2371.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks, I'm sorry to my careless.

2011/8/9 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mardi 09 ao=FBt 2011 =E0 23:18 +0800, stufever@gmail.com a =E9crit=
 :
>> From: Wang Shaoyan <wangshaoyan.pt@taobao.com>
>>
>> =A0 drivers/net/gianfar_ethtool.c:765: warning: the frame size of 20=
48 bytes is larger than 1024 bytes
>>
>> Signed-off-by: Wang Shaoyan <wangshaoyan.pt@taobao.com>
>> ---
>> =A0drivers/net/gianfar_ethtool.c | =A0 26 +++++++++++++++++++++++---
>> =A01 files changed, 23 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_eth=
tool.c
>> index 6e35069..039e9c3 100644
>> --- a/drivers/net/gianfar_ethtool.c
>> +++ b/drivers/net/gianfar_ethtool.c
>> @@ -686,10 +686,26 @@ static int gfar_ethflow_to_filer_table(struct =
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
>> + =A0 =A0 if (local_rqfpr) {
>
> =A0 =A0 =A0 =A0if (!local_rqfpr) {
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 pr_err("Out of memory\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 got err;
>> + =A0 =A0 }
>> + =A0 =A0 local_rqfcr =3D kmalloc(sizeof(unsigned int) * (MAX_FILER_=
IDX + 1),
>> + =A0 =A0 =A0 =A0 =A0 =A0 GFP_KERNEL);
>> + =A0 =A0 if (local_rqfcr) {
>
> same here : if (!local_rqfcr) ...
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 pr_err("Out of memory\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto err1;
>> + =A0 =A0 }
>>
>> =A0 =A0 =A0 switch (class) {
>> =A0 =A0 =A0 case TCP_V4_FLOW:
>> @@ -765,7 +781,11 @@ static int gfar_ethflow_to_filer_table(struct g=
far_private *priv, u64 ethflow, u
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->cur_filer_idx =3D priv->cur_filer_=
idx - 1;
>> =A0 =A0 =A0 }
>>
>> - =A0 =A0 return 1;
>> + =A0 =A0 kfree(local_rqfcr);
>> +err1:
>> + =A0 =A0 kfree(local_rqfpr);
>> +err:
>> + =A0 =A0 return ret;
>> =A0}
>>
>> =A0static int gfar_set_hash_opts(struct gfar_private *priv, struct e=
thtool_rxnfc *cmd)
>
>
>



--=20
Wang Shaoyan
