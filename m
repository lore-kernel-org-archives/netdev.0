From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 5/5 v4] net: add old_queue_mapping into skb->cb
Date: Thu, 23 Dec 2010 08:00:20 -0500
Message-ID: <1293109220.11306.137.camel@mojatatu>
References: <1292475410-24665-1-git-send-email-xiaosuo@gmail.com>
	 <1292591363.2668.19.camel@mojatatu>
	 <AANLkTi=Eq1HuPwMMGQjk9x0QXp3_5djmAY6JeZyFkk0k@mail.gmail.com>
	 <1292936837.6535.8.camel@mojatatu>
	 <AANLkTimqemuhxCKq-PJu+FD-MDgKaHnYKnP_2ch30wxE@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:64869 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676Ab0LWNAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 08:00:24 -0500
Received: by gwj20 with SMTP id 20so3524400gwj.19
        for <netdev@vger.kernel.org>; Thu, 23 Dec 2010 05:00:23 -0800 (PST)
In-Reply-To: <AANLkTimqemuhxCKq-PJu+FD-MDgKaHnYKnP_2ch30wxE@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-12-21 at 22:03 +0800, Changli Gao wrote:

> When I tested it, my OS got frozen.

I will look into it the next opportunity i get. The example i showed
is on egress btw. A ping from outside that matches the filter
will be a good test.

> Currently, you can only change the rx queue mapping, because for tx,
> dev_pick_tx() doesn't use skb->queue_mapping to choose tx queue.

If skbedit is on egress, it will happen after (and override whatever
dev_pick_tx() chose), no? Thats the whole point for skbedits queuemap
editing.

> However, I don't think change the rx queue mapping is a good idea.

I agree for that as a default policy. But it is
policy that skbedit can and should be able to override.

> When the skbs returned from ifb enter netif_receive_skb() again,
> get_rps_cpu() may warn about the wrong rx queue, and my this patch is
> used to solve this problem. Even though the rx queue is legal, a
> different rps_cpus settings will be used, and the skbs may be
> redirected to different CPUs. Is it expected?

I am not sure without analyzing what performance impact would be, i.e i
think that the only reason i wouldnt do it is because it may have crazy
effect on performance but:
If i wanted to override the choice made by rps through some policy, why
shouldnt i be able to do it? Same thing if i wanted to bypass rps. tc
level seems appropriate.
I may be misreading the code: Quick glance at the code indicates users
have no choice on ingress: rps happens first then we can do tc level -
so it doesnt matter what changes we make to the queue map it will not
take effect in any case. Am i mistaken?

cheers,
jamal

