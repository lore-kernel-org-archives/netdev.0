From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 5/5 v4] net: add old_queue_mapping into skb->cb
Date: Tue, 21 Dec 2010 22:03:40 +0800
Message-ID: <AANLkTimqemuhxCKq-PJu+FD-MDgKaHnYKnP_2ch30wxE@mail.gmail.com>
References: <1292475410-24665-1-git-send-email-xiaosuo@gmail.com>
 <1292591363.2668.19.camel@mojatatu> <AANLkTi=Eq1HuPwMMGQjk9x0QXp3_5djmAY6JeZyFkk0k@mail.gmail.com>
 <1292936837.6535.8.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:33197 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab0LUOEB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 09:04:01 -0500
Received: by fxm18 with SMTP id 18so4341581fxm.2
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 06:04:00 -0800 (PST)
In-Reply-To: <1292936837.6535.8.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 21, 2010 at 9:07 PM, jamal <hadi@cyberus.ca> wrote:
> On Fri, 2010-12-17 at 21:41 +0800, Changli Gao wrote:
>
> Sorry for the latency - I am a little swamped.
>
>> I doubt it can work.
>
> It should work - this used to be part of my regression tests.
> If it doesnt work something is broken.

When I tested it, my OS got frozen.

>
> In any case, I shouldnt have used this example because
> it distracted from the point i was trying to make:
> You are restoring the old qmap when the point is we could change
> it to a new one. A simpler example illustrating how
> a qmap could be changed:
>
> ----
> tc filter add dev ifb0 parent 1:0 protocol ip prio 10 u32 \
> =A0match u32 0 0 flowid 1:2 \
> =A0action skbedit queue_mapping 4
> ----

Currently, you can only change the rx queue mapping, because for tx,
dev_pick_tx() doesn't use skb->queue_mapping to choose tx queue.

However, I don't think change the rx queue mapping is a good idea.
When the skbs returned from ifb enter netif_receive_skb() again,
get_rps_cpu() may warn about the wrong rx queue, and my this patch is
used to solve this problem. Even though the rx queue is legal, a
different rps_cpus settings will be used, and the skbs may be
redirected to different CPUs. Is it expected?


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
