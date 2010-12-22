From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 5/5 v4] net: add old_queue_mapping into skb->cb
Date: Wed, 22 Dec 2010 08:08:10 +0800
Message-ID: <AANLkTi=W6fL_W_UGUbM9aTEDO_ea46zEp9kg-tL=0rwr@mail.gmail.com>
References: <1292475410-24665-1-git-send-email-xiaosuo@gmail.com>
 <1292591363.2668.19.camel@mojatatu> <AANLkTi=Eq1HuPwMMGQjk9x0QXp3_5djmAY6JeZyFkk0k@mail.gmail.com>
 <1292936837.6535.8.camel@mojatatu> <AANLkTimqemuhxCKq-PJu+FD-MDgKaHnYKnP_2ch30wxE@mail.gmail.com>
 <1292945075.2720.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: hadi@cyberus.ca, "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:61519 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262Ab0LVAIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 19:08:32 -0500
Received: by fxm18 with SMTP id 18so5000446fxm.2
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 16:08:30 -0800 (PST)
In-Reply-To: <1292945075.2720.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 21, 2010 at 11:24 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Do we really want a multi queue ifb at all ?
>
> Why not use percpu data and LLTX, like we did for other virtual devices
> (loopback, tunnels, vlans, ...)
>
> I guess most ifb uses need to finaly deliver packets in a monoqueue
> anyway, optimizing ifb might raise lock contention on this resource.
>

For ingress shaping, the later processing should be in parallel, so
multiple ri_tasklets are needed.

For one queue ifb, the queue mapping should be saved and restored for
ingress skbs, as it is reset to 0 in dev_pick_tx(ifb).


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
