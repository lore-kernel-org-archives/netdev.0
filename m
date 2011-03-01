From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] bonding: remove skb_share_check in handle_frame
Date: Tue, 01 Mar 2011 21:11:29 +0100
Message-ID: <4D6D52F1.6020407@gmail.com>
References: <20110301062250.GB2855@psychotron.redhat.com> <20110301092907.GG2855@psychotron.redhat.com> <AANLkTimk_jyTYO8=8LRgY3C1un38qb1q9C-DbKWHirPS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34813 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756258Ab1CAULx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 15:11:53 -0500
Received: by fxm17 with SMTP id 17so5193102fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 12:11:52 -0800 (PST)
In-Reply-To: <AANLkTimk_jyTYO8=8LRgY3C1un38qb1q9C-DbKWHirPS@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/03/2011 16:12, Changli Gao a =E9crit :
> On Tue, Mar 1, 2011 at 5:29 PM, Jiri Pirko<jpirko@redhat.com>  wrote:
>> Unapplicable, sorry (wrong branch :(). Here's corrected patch:
>>
>> Subject: [PATCH net-next-2.6 v2] bonding: remove skb_share_check in =
handle_frame
>>
>> No need to do share check here.
>>
>
> I don't think so. Although you avoid netif_rx(), you can't avoid
> ptype_all handlers. In fact, all the RX handlers should has this
> check(), if they may modify the skb.

Can you please develop your explanation?

In current __netif_receive_skb() (after the recent patch from Jiri), we=
 deliver the skb to ptype_all=20
handlers inside a loop, while possibly changing skb->dev inside this lo=
op.

Then, at the end of __netif_receive_skb(), we loop on ptype_base, witho=
ut changing anything in skb.

Should we consider ptype_*->func() to be called in a pure sequential wa=
y? Should we consider that=20
when a ptype_*->func() returns, nothing from this handler will use the =
skb in anyway later, in a=20
parallel way?

Or should we, instead, consider that special precautions must be taken,=
 because protocol handlers=20
may run in parallel for the same skb? Which kind of precautions?

Thanks.

	Nicolas.
