From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Thu, 16 Dec 2010 22:20:59 +0800
Message-ID: <AANLkTim--M0TvW9oUi0UO6Ej_8aLezneQsdRx7X0CXDt@mail.gmail.com>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
	<1292483902.2603.62.camel@edumazet-laptop>
	<AANLkTi=BX8AMaiwV3aDAVqRA=br00eRo-42vPNwZfwS6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Xinan Tang <xinan.tang@intel.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:37010 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756093Ab0LPOVA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 09:21:00 -0500
Received: by fxm18 with SMTP id 18so3306916fxm.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 06:20:59 -0800 (PST)
In-Reply-To: <AANLkTi=BX8AMaiwV3aDAVqRA=br00eRo-42vPNwZfwS6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 3:23 PM, Changli Gao <xiaosuo@gmail.com> wrote:

>> You beat me, but I was thinking of a different way, adding a new
>> pt_prev->xmit_func(), handling all the details (no need for atomic o=
ps
>> on skb users if packet is not delivered at all).
>>
>> By the way, your patch is not 100% safe/OK, because af_packet rcv()
>> handler writes on skb (skb_pull() and all)
>>
>
> But af_packet_rcv() restores skbs at last.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb_head !=3D skb->data && skb_shared(=
skb)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb->data =3D =
skb_head;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb->len =3D s=
kb_len;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
If af packet_rcv invokes skb_clone, this skb is differ from the origina=
l one.
Eric's warning is right.


--=20
--Junchang
