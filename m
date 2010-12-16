From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Thu, 16 Dec 2010 22:31:34 +0800
Message-ID: <AANLkTimd96KoT1-KqeiF7i10pH3pfML=rsUho=cCancU@mail.gmail.com>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
	<AANLkTikdYi-Cs=4UtjJx-X4bW+LSKTQBTcSv23NS2S+S@mail.gmail.com>
	<1292509118.2883.167.camel@edumazet-laptop>
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
Received: from mail-fx0-f43.google.com ([209.85.161.43]:43742 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755953Ab0LPOby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 09:31:54 -0500
Received: by fxm18 with SMTP id 18so3320846fxm.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 06:31:53 -0800 (PST)
In-Reply-To: <1292509118.2883.167.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 10:18 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Yes, and no.
>
> Consider the case you have one receiver.
>
> Packet given after Changli patch wont be shared, so packet_rcv wont
> clone it : Thats a win. Only one skb_clone() done instead of two.
>
> Consider case with 2 receivers :
>
> First time we call packet_rcv, packet is shared (because we call
> deliver_skb(), so packet_rcv clones it. Normal situation, we really need
> to clone it.

Got it. Thanks.

>
> Second time, we give a non shared packet : Thats a win over previous
> situation.
>
But, if we have N receivers, we get only the last one win - the first N-1 will
call deliver_skb().


Thanks.
-- 
--Junchang
