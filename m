From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Thu, 16 Dec 2010 22:43:47 +0800
Message-ID: <AANLkTinxyKpzXS4k63n64S9Fa+4uNUo6-UMdt8OqQs37@mail.gmail.com>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
 <AANLkTikdYi-Cs=4UtjJx-X4bW+LSKTQBTcSv23NS2S+S@mail.gmail.com>
 <1292509118.2883.167.camel@edumazet-laptop> <AANLkTimd96KoT1-KqeiF7i10pH3pfML=rsUho=cCancU@mail.gmail.com>
 <1292510518.2883.207.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Junchang Wang <junchangwang@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Xinan Tang <xinan.tang@intel.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:50388 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755869Ab0LPOoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 09:44:09 -0500
Received: by fxm18 with SMTP id 18so3335999fxm.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 06:44:08 -0800 (PST)
In-Reply-To: <1292510518.2883.207.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 10:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
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
> If I undertood patch intent ;)
>

Yes, you got it. :)

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
