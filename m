From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v5] net: batch skb dequeueing from softnet input_pkt_queue
Date: Thu, 22 Apr 2010 22:54:27 +0800
Message-ID: <q2p412e6f7f1004220754ye723ac1aoc291048312b5818f@mail.gmail.com>
References: <1271927357-2973-1-git-send-email-xiaosuo@gmail.com>
	<1271936227.7895.5285.camel@edumazet-laptop> <y2n412e6f7f1004220606id324dc9bj2cc04cfbad50a101@mail.gmail.com>
	<1271946805.7895.5658.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:60790 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755212Ab0DVOyz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 10:54:55 -0400
Received: by pzk32 with SMTP id 32so5466621pzk.21
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 07:54:55 -0700 (PDT)
In-Reply-To: <1271946805.7895.5658.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 10:33 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>
> It does make a difference, Damn it.
>
> I really really start to think you dont read what I wrote, or you don=
t
> care.

I misunderstood it. Sorry.

>
> Damn, cant you update all the things at once, taking this lock only
> once ?
>
> You focus having an ultra precise count of pkt_queue.len, but we dont
> care at all ! We only want a _limit_, or else the box can be killed b=
y
> DOS.
>
> If in practice this limit can be 2*limit, thats OK.
>
> Cant you understand this ?
>
>
> We need one limit. Not two limits.
>
> I already told you how to do it, but you ignored me and started yet
> another convoluted thing.
>
>
> process_backlog() transfert the queue to its own queue and reset pkt_=
len
> to 0 (Only once)
>
> End of story.
>
> Maximum packet queued to this cpu softnet_data will be 2 * old_limit.
>
> So what ?
>

Now, I think I really understand. We don't need a precious limit. So
only a additional queue is enough.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
