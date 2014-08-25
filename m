From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next v3 09/12] net: dsa: add Broadcom tag RX/TX handler
Date: Mon, 25 Aug 2014 07:51:20 -0700
Message-ID: <53FB4D68.9020300@intel.com>
References: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com> <1408905869-10471-10-git-send-email-f.fainelli@gmail.com> <53FA6C55.5040903@gmail.com> <53FAA158.6050600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, jhs@mojatatu.com, linville@tuxdriver.com
To: Florian Fainelli <f.fainelli@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41546 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933167AbaHYOv1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 10:51:27 -0400
In-Reply-To: <53FAA158.6050600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2014 07:37 PM, Florian Fainelli wrote:
> Le 24/08/2014 15:51, Alexander Duyck a =E9crit :
>> On 08/24/2014 11:44 AM, Florian Fainelli wrote:
>>> +
>>> +static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *de=
v,
>>> +            struct packet_type *pt, struct net_device *orig_dev)
>>> +{
>>> +    struct dsa_switch_tree *dst =3D dev->dsa_ptr;
>>> +    struct dsa_switch *ds;
>>> +    int source_port;
>>> +    u8 *brcm_tag;
>>> +
>>> +    if (unlikely(dst =3D=3D NULL))
>>> +        goto out_drop;
>>> +
>>> +    ds =3D dst->ds[0];
>>> +
>>> +    skb =3D skb_unshare(skb, GFP_ATOMIC);
>>> +    if (skb =3D=3D NULL)
>>> +        goto out;
>>
>> At this point here we already have the dsa pointers and could just p=
ull
>> up a function pointer so all of the code below could potentially be
>> moved into a separate function allowing us to drop the need to have
>> multiple Ethertypes and so we could just use ETH_P_DSA for all DSA
>> tagging type.
>=20
> I see, or rather maybe just use ETH_P_EDSA which is a real assigned
> ethertype?
> --=20
> Florian

I suppose we could probably do that.  Although I would probably say we
should just rename it to ETH_P_DSA since we can just go through and dro=
p
all of the other defined Ethertypes for DSA.  In addition since the EDS=
A
isn't actually a registered type we probably don't need to bother with
conserving the name anyway.

Thanks,

Alex
