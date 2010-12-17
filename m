From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Fri, 17 Dec 2010 08:24:49 +0800
Message-ID: <AANLkTi=Ri40-q20tvrRwMDcrUVVHQ69FFtGrM4NRbuuE@mail.gmail.com>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
	<AANLkTikdYi-Cs=4UtjJx-X4bW+LSKTQBTcSv23NS2S+S@mail.gmail.com>
	<1292509118.2883.167.camel@edumazet-laptop>
	<AANLkTimd96KoT1-KqeiF7i10pH3pfML=rsUho=cCancU@mail.gmail.com>
	<1292510518.2883.207.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Xinan Tang <xinan.tang@intel.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:38222 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669Ab0LQAYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 19:24:51 -0500
Received: by fxm18 with SMTP id 18so146814fxm.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 16:24:49 -0800 (PST)
In-Reply-To: <1292510518.2883.207.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 10:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> But, if we have N receivers, we get only the last one win - the first N-1 will
>> call deliver_skb().
>>
>
> Yes, but you want to, because each receiver has to make a private copy
> of the skb.
>
> The big win is that if packet if filtered out (not accepted by the
> socket filter), you end with no extra skb_clone() at all.
>
> Say you have 8 receivers, with a filter matching some hash/cpu, and only
> one af_packet socket will take the message.
>
> Before patch : 8 skb_clones()
>
> After patch : one skb_clone()
>
Now I understand. :)
The patch is fine. Thanks Changli and Eric.



-- 
--Junchang
