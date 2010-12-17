From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 5/5 v4] net: add old_queue_mapping into skb->cb
Date: Fri, 17 Dec 2010 08:09:23 -0500
Message-ID: <1292591363.2668.19.camel@mojatatu>
References: <1292475410-24665-1-git-send-email-xiaosuo@gmail.com>
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
Received: from mail-gw0-f42.google.com ([74.125.83.42]:42205 "EHLO
	mail-gw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120Ab0LQNJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 08:09:20 -0500
Received: by gwb20 with SMTP id 20so418704gwb.1
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 05:09:20 -0800 (PST)
In-Reply-To: <1292475410-24665-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-12-16 at 12:56 +0800, Changli Gao wrote:
> For the skbs returned from ifb, we should use the queue_mapping
> saved before ifb.
> 
> We save old queue_mapping in old_queue_mapping just before calling 
> dev_queue_xmit, and restore the old_queue_mapping to queue_mapping
> just before reinjecting the ingress packets.
> 
> A new struct dev_skb_cb is added, and valid in qdisc and gso layer.
> The original qdisc_skb_cb and DEV_GSO_CB use dev_skb_cb as the first
> member.
> 
> netem_skb_cb is changed to contain qdisc_skb_cb.

I am sorry Changli - I think we are talking past each other. I
a conflicted on the whole point of saving and restoring these
devqueue mappings. I understand that for ifb, saving and restoring the
original devs is fundamental for its operation- but i am not sure i see
it for the queues. As an example:

---
# For all packets arriving on ifb0, change mapping to 3 and
# redirect to to ifb1

tc filter add dev ifb0 parent 1:0 protocol ip prio 10 u32 \
match u32 0 0 flowid 1:2 \
action skbedit queue_mapping 4 \
action mirred egress redirect dev ifb1
#
# redirect all packets arriving in eth0 to ifb0
$TC filter add eth0 parent 1:0 protocol ip prio 10 u32 \
match u32 0 0 flowid 1:2 action mirred egress redirect dev ifb0
----

what is the expected behavior?

cheers,
jamal

