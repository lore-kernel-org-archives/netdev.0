From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] bonding: remove skb_share_check in
 handle_frame
Date: Wed, 2 Mar 2011 22:12:38 +0100
Message-ID: <20110302211238.GC3360@psychotron.redhat.com>
References: <20110301062250.GB2855@psychotron.redhat.com>
 <20110301092907.GG2855@psychotron.redhat.com>
 <20110301203843.GN11864@gospo.rdu.redhat.com>
 <20110302100354.GB2858@psychotron.brq.redhat.com>
 <4D6EACF6.2040005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	davem@davemloft.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33450 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753067Ab1CBVMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 16:12:44 -0500
Content-Disposition: inline
In-Reply-To: <4D6EACF6.2040005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 02, 2011 at 09:47:50PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 02/03/2011 11:03, Jiri Pirko a =E9crit :
>>Tue, Mar 01, 2011 at 09:38:43PM CET, andy@greyhouse.net wrote:
>>>On Tue, Mar 01, 2011 at 10:29:07AM +0100, Jiri Pirko wrote:
>>>>Unapplicable, sorry (wrong branch :(). Here's corrected patch:
>>>>
>>>>Subject: [PATCH net-next-2.6 v2] bonding: remove skb_share_check in=
 handle_frame
>>>>
>>>>No need to do share check here.
>>>>
>>>>Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>>>---
>>>>  drivers/net/bonding/bond_main.c |    3 ---
>>>>  1 files changed, 0 insertions(+), 3 deletions(-)
>>>>
>>>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/=
bond_main.c
>>>>index 584f97b..367ea60 100644
>>>>--- a/drivers/net/bonding/bond_main.c
>>>>+++ b/drivers/net/bonding/bond_main.c
>>>>@@ -1498,9 +1498,6 @@ static struct sk_buff *bond_handle_frame(stru=
ct sk_buff *skb)
>>>>  	struct net_device *slave_dev;
>>>>  	struct net_device *bond_dev;
>>>>
>>>>-	skb =3D skb_share_check(skb, GFP_ATOMIC);
>>>>-	if (unlikely(!skb))
>>>>-		return NULL;
>>>>  	slave_dev =3D skb->dev;
>>>>  	bond_dev =3D ACCESS_ONCE(slave_dev->master);
>>>>  	if (unlikely(!bond_dev))
>>>>--
>>>>1.7.3.4
>>>>
>>>
>>>Why did you decide to get rid of it here rather than the 3 places in=
 the
>>>bonding driver where it is currently needed?  I think this can cover
>>>those cases since bond_handle_frame will be called after the ptype_a=
ll
>>>handlers before any of the ptype handlers.
>>
>>I have already a patch prepared which converts bond ptype handlers in=
to
>>being called from bond_handle_frame. You are propably right that this
>>should probably stay here.
>
>Hi Jiri,
>
>Do you plan to call the bonding ARP handler from inside bond_handle_fr=
ame()?

I do - it's part of patchset I've cooked (going to test that tomorrow).

>
>A few days ago
>(http://marc.info/?l=3Dlinux-netdev&m=3D129883949022340&w=3D2), I noti=
ced
>that it is not possible to call the bonding ARP handler from inside
>the bonding rx_handler, because some frame processing may be required
>after the bonding rx_handler call, to put the frame in a suitable
>state for the bonding ARP handler.

Do you see another scenario besides the next one?

>
>This is at least true with the following setup, eth0 -> bond0 ->
>bond0.100, where the ARP frames are VLAN tagged at the time the
>bonding rx_handler process them.

Isn't this scenario resolved by vlan_on_bond_hook ?

eth0
  ->rx_handler -> another round
bond0
  ->vlan_hwaccel_do_receive -> __netif_receive_skb
bond0.100
  ->vlan_on_bond_hook -> reinject to bond0


>
>	Nicolas.
