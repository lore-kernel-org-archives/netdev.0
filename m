From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] bonding: remove skb_share_check in handle_frame
Date: Wed, 02 Mar 2011 21:47:50 +0100
Message-ID: <4D6EACF6.2040005@gmail.com>
References: <20110301062250.GB2855@psychotron.redhat.com> <20110301092907.GG2855@psychotron.redhat.com> <20110301203843.GN11864@gospo.rdu.redhat.com> <20110302100354.GB2858@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	davem@davemloft.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56277 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516Ab1CBUry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 15:47:54 -0500
Received: by wwb22 with SMTP id 22so508361wwb.1
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 12:47:53 -0800 (PST)
In-Reply-To: <20110302100354.GB2858@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/03/2011 11:03, Jiri Pirko a =E9crit :
> Tue, Mar 01, 2011 at 09:38:43PM CET, andy@greyhouse.net wrote:
>> On Tue, Mar 01, 2011 at 10:29:07AM +0100, Jiri Pirko wrote:
>>> Unapplicable, sorry (wrong branch :(). Here's corrected patch:
>>>
>>> Subject: [PATCH net-next-2.6 v2] bonding: remove skb_share_check in=
 handle_frame
>>>
>>> No need to do share check here.
>>>
>>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>> ---
>>>   drivers/net/bonding/bond_main.c |    3 ---
>>>   1 files changed, 0 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/=
bond_main.c
>>> index 584f97b..367ea60 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -1498,9 +1498,6 @@ static struct sk_buff *bond_handle_frame(stru=
ct sk_buff *skb)
>>>   	struct net_device *slave_dev;
>>>   	struct net_device *bond_dev;
>>>
>>> -	skb =3D skb_share_check(skb, GFP_ATOMIC);
>>> -	if (unlikely(!skb))
>>> -		return NULL;
>>>   	slave_dev =3D skb->dev;
>>>   	bond_dev =3D ACCESS_ONCE(slave_dev->master);
>>>   	if (unlikely(!bond_dev))
>>> --
>>> 1.7.3.4
>>>
>>
>> Why did you decide to get rid of it here rather than the 3 places in=
 the
>> bonding driver where it is currently needed?  I think this can cover
>> those cases since bond_handle_frame will be called after the ptype_a=
ll
>> handlers before any of the ptype handlers.
>
> I have already a patch prepared which converts bond ptype handlers in=
to
> being called from bond_handle_frame. You are propably right that this
> should probably stay here.

Hi Jiri,

Do you plan to call the bonding ARP handler from inside bond_handle_fra=
me()?

A few days ago (http://marc.info/?l=3Dlinux-netdev&m=3D129883949022340&=
w=3D2), I noticed that it is not=20
possible to call the bonding ARP handler from inside the bonding rx_han=
dler, because some frame=20
processing may be required after the bonding rx_handler call, to put th=
e frame in a suitable state=20
for the bonding ARP handler.

This is at least true with the following setup, eth0 -> bond0 -> bond0.=
100, where the ARP frames are=20
VLAN tagged at the time the bonding rx_handler process them.

	Nicolas.
