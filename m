From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: harmonize the call to ptype_all and
 ptype_base handlers.
Date: Mon, 07 Mar 2011 21:41:19 +0100
Message-ID: <4D7542EF.5000201@gmail.com>
References: <4D738751.6050209@gmail.com> <1299417916-14198-1-git-send-email-nicolas.2p.debian@free.fr> <20110307100318.GD2832@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?= <nicolas.2p.debian@free.fr>,
	netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	eric.dumazet@gmail.com, kaber@trash.net, fubar@us.ibm.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50134 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756073Ab1CGUlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 15:41:21 -0500
Received: by wyg36 with SMTP id 36so4562699wyg.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 12:41:20 -0800 (PST)
In-Reply-To: <20110307100318.GD2832@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/03/2011 11:03, Jiri Pirko a =E9crit :
> Sun, Mar 06, 2011 at 02:25:16PM CET, nicolas.2p.debian@free.fr wrote:
>> Until now, ptype_all and ptype_base delivery in __netif_receive_skb(=
) is
>> inconsistent.
>>
>> - For ptype_all, we deliver to every device crossed while walking th=
e
>> rx_handler path (inside the another_round loop), and there is no way=
 to stop
>> wildcard delivery (no exact match logic).
>> - For ptype_base, we deliver to the lowest device (orig_dev) and to =
the highest
>> (skb->dev) and we can ask for exact match delivery.
>>
>> This patch try and fix this, by:
>>
>> 1/ Doing exact match delivery for both ptype_all and ptype_base, whi=
le walking
>>    the rx_handler path.
>> 2/ Doing wildcard match delivery at the end of __netif_receive_skb()=
, if not
>>    asked to do exact match delivery only.
>>
>> Signed-off-by: Nicolas de Peslo=FCan<nicolas.2p.debian@free.fr>
>> ---
>>
>> This apply on top of the last batch of patch from Jiri Pirko.
>> ---
>> net/core/dev.c |   32 ++++++++++++++++++++++++--------
>> 1 files changed, 24 insertions(+), 8 deletions(-)
>>
>
> I tend to like this patch. However I'm not sure if extra 2 loops don'=
t
> introduce noticable overhead :/

I think ptype_all and ptype_base lists should only contain entries havi=
ng ptype->dev =3D=3D NULL.

The entries having ptype->dev !=3D NULL should be on per net_device lis=
ts. The head of those lists=20
could/should be in a ptype_all and a ptype_base property in net_device.

This would speed up the exact-match loops, because they would scan smal=
l (or empty) lists.

I need to double check the possible impact of this proposal.

	Nicolas.
