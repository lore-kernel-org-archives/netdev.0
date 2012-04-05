From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next V6 7/8] net/dcb: Add an optional max rate attribute
Date: Wed, 4 Apr 2012 17:39:51 -0700
Message-ID: <CAA93jw6EJgb83e4cqmz3pPyuxsLEA+SFyFOLb5Up_-f538NFGg@mail.gmail.com>
References: <1333537084-9186-1-git-send-email-amirv@mellanox.com>
	<1333537084-9186-8-git-send-email-amirv@mellanox.com>
	<4F7CE61E.7060406@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Amir Vadai <amirv@mellanox.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35716 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab2DEAjx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 20:39:53 -0400
Received: by wejx9 with SMTP id x9so522005wej.19
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 17:39:52 -0700 (PDT)
In-Reply-To: <4F7CE61E.7060406@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(I try not to pay too much attention to the DCB stuff as it gives me ni=
ghtmares)

It would comfort me to know if or which of:

Is 802.1au being implemented?

802.3bd?

There was some other standard involving active queue management at
this layer that I can't remember the alphabet soup for that must be
dead in the water at this point..

http://www.ieee802.org/1/files/public/docs2009/au-yasuda-10G-QCN-Implem=
entation-1109.pdf


On Wed, Apr 4, 2012 at 5:23 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> On 4/4/2012 3:58 AM, Amir Vadai wrote:
>> Although not specified in 8021Qaz spec, it could be useful to enable=
 drivers
>> whose HW supports setting a rate limit for an ETS TC. This patch add=
s this
>> optional attribute to DCB netlink. To use it, drivers should impleme=
nt and
>> register the callbacks ieee_setmaxrate and ieee_getmaxrate. The unit=
s are 64
>> bits long and specified in Kbps to enable usage over both slow and v=
ery fast
>> networks.
>>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>
> Or, Amir,
>
> Two more comments inline really just minor nit picks but if your goin=
g
> to roll new patch mind as well. I'll ack a patch with these changes.
>
>> =A0include/linux/dcbnl.h | =A0 =A05 +++++
>> =A0include/net/dcbnl.h =A0 | =A0 =A02 ++
>> =A0net/dcb/dcbnl.c =A0 =A0 =A0 | =A0 21 +++++++++++++++++++++
>> =A03 files changed, 28 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
>> index 65a2562..ec8e372 100644
>> --- a/include/linux/dcbnl.h
>> +++ b/include/linux/dcbnl.h
>> @@ -67,6 +67,10 @@ struct ieee_ets {
>> =A0 =A0 =A0 __u8 =A0 =A0reco_prio_tc[IEEE_8021QAZ_MAX_TCS];
>> =A0};
>>
>
> annotate ieee_maxrate so implementers use it correctly per previous n=
ote.
>
>> +struct ieee_maxrate {
>> + =A0 =A0 __u64 =A0 tc_maxrate[IEEE_8021QAZ_MAX_TCS];
>> +};
>> +
>> =A0/* This structure contains the IEEE 802.1Qaz PFC managed object
>> =A0 *
>> =A0 * @pfc_cap: Indicates the number of traffic classes on the local=
 device
>> @@ -321,6 +325,7 @@ enum ieee_attrs {
>> =A0 =A0 =A0 DCB_ATTR_IEEE_PEER_ETS,
>> =A0 =A0 =A0 DCB_ATTR_IEEE_PEER_PFC,
>> =A0 =A0 =A0 DCB_ATTR_IEEE_PEER_APP,
>> + =A0 =A0 DCB_ATTR_IEEE_MAXRATE,
>> =A0 =A0 =A0 __DCB_ATTR_IEEE_MAX
>> =A0};
>> =A0#define DCB_ATTR_IEEE_MAX (__DCB_ATTR_IEEE_MAX - 1)
>> diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
>> index f55c980..fc5d5dc 100644
>> --- a/include/net/dcbnl.h
>> +++ b/include/net/dcbnl.h
>> @@ -48,6 +48,8 @@ struct dcbnl_rtnl_ops {
>> =A0 =A0 =A0 /* IEEE 802.1Qaz std */
>> =A0 =A0 =A0 int (*ieee_getets) (struct net_device *, struct ieee_ets=
 *);
>> =A0 =A0 =A0 int (*ieee_setets) (struct net_device *, struct ieee_ets=
 *);
>> + =A0 =A0 int (*ieee_getmaxrate) (struct net_device *, struct ieee_m=
axrate *);
>> + =A0 =A0 int (*ieee_setmaxrate) (struct net_device *, struct ieee_m=
axrate *);
>> =A0 =A0 =A0 int (*ieee_getpfc) (struct net_device *, struct ieee_pfc=
 *);
>> =A0 =A0 =A0 int (*ieee_setpfc) (struct net_device *, struct ieee_pfc=
 *);
>> =A0 =A0 =A0 int (*ieee_getapp) (struct net_device *, struct dcb_app =
*);
>> diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
>> index 36f37af..d3df048 100644
>> --- a/net/dcb/dcbnl.c
>> +++ b/net/dcb/dcbnl.c
>> @@ -178,6 +178,8 @@ static const struct nla_policy dcbnl_ieee_policy=
[DCB_ATTR_IEEE_MAX + 1] =3D {
>> =A0 =A0 =A0 [DCB_ATTR_IEEE_ETS] =A0 =A0 =A0 =A0 =3D {.len =3D sizeof=
(struct ieee_ets)},
>> =A0 =A0 =A0 [DCB_ATTR_IEEE_PFC] =A0 =A0 =A0 =A0 =3D {.len =3D sizeof=
(struct ieee_pfc)},
>> =A0 =A0 =A0 [DCB_ATTR_IEEE_APP_TABLE] =A0 =3D {.type =3D NLA_NESTED}=
,
>> + =A0 =A0 [DCB_ATTR_IEEE_MAXRATE] =A0 =3D {.len =3D sizeof(struct ie=
ee_maxrate)},
>> +
>
> spurious newline remove it
>
>> =A0};
>>
>> =A0static const struct nla_policy dcbnl_ieee_app[DCB_ATTR_IEEE_APP_M=
AX + 1] =3D {
>> @@ -1246,6 +1248,17 @@ static int dcbnl_ieee_fill(struct sk_buff *sk=
b, struct net_device *netdev)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nla_put_failure;
>> =A0 =A0 =A0 }
>>
>> + =A0 =A0 if (ops->ieee_getmaxrate) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct ieee_maxrate maxrate;
>> + =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->ieee_getmaxrate(netdev, &maxr=
ate);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!err) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D nla_put(skb, DCB_A=
TTR_IEEE_MAXRATE,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 sizeof(maxrate), &maxrate);
>
> align sizeof with skb
>
> Thanks,
> John
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://www.bufferbloat.net
