From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 5/5 v4] net: add old_queue_mapping into skb->cb
Date: Thu, 23 Dec 2010 08:21:43 -0500
Message-ID: <1293110503.11306.156.camel@mojatatu>
References: <1292475410-24665-1-git-send-email-xiaosuo@gmail.com>
	 <1292591363.2668.19.camel@mojatatu>
	 <AANLkTi=Eq1HuPwMMGQjk9x0QXp3_5djmAY6JeZyFkk0k@mail.gmail.com>
	 <1292936837.6535.8.camel@mojatatu>
	 <AANLkTimqemuhxCKq-PJu+FD-MDgKaHnYKnP_2ch30wxE@mail.gmail.com>
	 <1292945075.2720.32.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:61622 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986Ab0LWNVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 08:21:46 -0500
Received: by ywl5 with SMTP id 5so2617910ywl.19
        for <netdev@vger.kernel.org>; Thu, 23 Dec 2010 05:21:45 -0800 (PST)
In-Reply-To: <1292945075.2720.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-12-21 at 16:24 +0100, Eric Dumazet wrote:

> 
> Do we really want a multi queue ifb at all ?
> 
> Why not use percpu data and LLTX, like we did for other virtual devices
> (loopback, tunnels, vlans, ...)
> 
> I guess most ifb uses need to finaly deliver packets in a monoqueue
> anyway, optimizing ifb might raise lock contention on this resource.

I guess once you start having hardware that is multiqueue on the ingress
side at least then something per cpu is needed on ifb. But i agree that
the optimizations may end up harming the simplicity that ifb intended.
It is already jumping a lot of hoops to work around things as is.

> See what we did in commit 79640a4ca6955e3e (net: add additional lock to
> qdisc to increase throughput) : Adding one spinlock actually helped a
> lot ;)

Yes, that was fascinating stuff;-> I am still scratching my head and
continuing to itch on when i can get more time to look closely with some
testing. But i dont see the connection with what Changli is attempting
with multiq ifb - what do you have in mind.

cheers,
jamal



