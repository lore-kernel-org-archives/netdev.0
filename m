From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] net: harmonize the call to ptype_all and
 ptype_base handlers.
Date: Mon, 7 Mar 2011 22:12:43 +0100
Message-ID: <20110307211242.GA3266@psychotron.redhat.com>
References: <4D738751.6050209@gmail.com>
 <1299417916-14198-1-git-send-email-nicolas.2p.debian@free.fr>
 <20110307100318.GD2832@psychotron.brq.redhat.com>
 <4D7542EF.5000201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@free.fr>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@vyatta.com, eric.dumazet@gmail.com,
	kaber@trash.net, fubar@us.ibm.com, andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62007 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756120Ab1CGVMx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 16:12:53 -0500
Content-Disposition: inline
In-Reply-To: <4D7542EF.5000201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 07, 2011 at 09:41:19PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 07/03/2011 11:03, Jiri Pirko a =E9crit :
>>Sun, Mar 06, 2011 at 02:25:16PM CET, nicolas.2p.debian@free.fr wrote:
>>>Until now, ptype_all and ptype_base delivery in __netif_receive_skb(=
) is
>>>inconsistent.
>>>
>>>- For ptype_all, we deliver to every device crossed while walking th=
e
>>>rx_handler path (inside the another_round loop), and there is no way=
 to stop
>>>wildcard delivery (no exact match logic).
>>>- For ptype_base, we deliver to the lowest device (orig_dev) and to =
the highest
>>>(skb->dev) and we can ask for exact match delivery.
>>>
>>>This patch try and fix this, by:
>>>
>>>1/ Doing exact match delivery for both ptype_all and ptype_base, whi=
le walking
>>>   the rx_handler path.
>>>2/ Doing wildcard match delivery at the end of __netif_receive_skb()=
, if not
>>>   asked to do exact match delivery only.
>>>
>>>Signed-off-by: Nicolas de Peslo=FCan<nicolas.2p.debian@free.fr>
>>>---
>>>
>>>This apply on top of the last batch of patch from Jiri Pirko.
>>>---
>>>net/core/dev.c |   32 ++++++++++++++++++++++++--------
>>>1 files changed, 24 insertions(+), 8 deletions(-)
>>>
>>
>>I tend to like this patch. However I'm not sure if extra 2 loops don'=
t
>>introduce noticable overhead :/
>
>I think ptype_all and ptype_base lists should only contain entries hav=
ing ptype->dev =3D=3D NULL.
>
>The entries having ptype->dev !=3D NULL should be on per net_device
>lists. The head of those lists could/should be in a ptype_all and a
>ptype_base property in net_device.
>
>This would speed up the exact-match loops, because they would scan sma=
ll (or empty) lists.
>
>I need to double check the possible impact of this proposal.

On the first glance, this makes sense to me.

>
>	Nicolas.
