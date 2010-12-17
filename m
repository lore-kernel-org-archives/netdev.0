From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 5/5 v4] net: add old_queue_mapping into skb->cb
Date: Fri, 17 Dec 2010 21:41:55 +0800
Message-ID: <AANLkTi=Eq1HuPwMMGQjk9x0QXp3_5djmAY6JeZyFkk0k@mail.gmail.com>
References: <1292475410-24665-1-git-send-email-xiaosuo@gmail.com> <1292591363.2668.19.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:36715 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858Ab0LQOfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 09:35:34 -0500
Received: by fxm18 with SMTP id 18so705211fxm.2
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 06:35:33 -0800 (PST)
In-Reply-To: <1292591363.2668.19.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 17, 2010 at 9:09 PM, jamal <hadi@cyberus.ca> wrote:
> On Thu, 2010-12-16 at 12:56 +0800, Changli Gao wrote:
>
> I am sorry Changli - I think we are talking past each other. I
> a conflicted on the whole point of saving and restoring these
> devqueue mappings. I understand that for ifb, saving and restoring the
> original devs is fundamental for its operation- but i am not sure i see
> it for the queues. As an example:
>
> ---
> # For all packets arriving on ifb0, change mapping to 3 and
> # redirect to to ifb1
>
> tc filter add dev ifb0 parent 1:0 protocol ip prio 10 u32 \
> match u32 0 0 flowid 1:2 \
> action skbedit queue_mapping 4 \
> action mirred egress redirect dev ifb1
> #
> # redirect all packets arriving in eth0 to ifb0
> $TC filter add eth0 parent 1:0 protocol ip prio 10 u32 \
> match u32 0 0 flowid 1:2 action mirred egress redirect dev ifb0
> ----
>
> what is the expected behavior?
>

I doubt it can work.

eth0 -> ifb0: skb->skb_iif = eth0.
ifb0 -> ifb1: skb->skb_iif = ifb0
ifb1 -> ifb0: as skb->skb_iif == ifb0, skb->skb_iif = ifb1
ifb0 -> ifb1...
...

Did you test it?

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
