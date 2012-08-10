From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 09/14] netpoll: check netpoll tx status on the right
 device
Date: Fri, 10 Aug 2012 15:52:36 +0800
Message-ID: <1344585156.29601.4.camel@cr0>
References: <1344582637-18261-1-git-send-email-amwang@redhat.com>
	 <1344582637-18261-10-git-send-email-amwang@redhat.com>
	 <20120810072018.GA1543@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34329 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754856Ab2HJHwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 03:52:46 -0400
In-Reply-To: <20120810072018.GA1543@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-10 at 09:20 +0200, Jiri Pirko wrote:
> > 
> >+static inline int team_dev_queue_xmit(struct team *team, struct team_port *port,
> >+				      struct sk_buff *skb)
> >+{
> >+	BUILD_BUG_ON(sizeof(skb->queue_mapping) !=
> >+		     sizeof(qdisc_skb_cb(skb)->slave_dev_queue_mapping));
> >+	skb_set_queue_mapping(skb, qdisc_skb_cb(skb)->slave_dev_queue_mapping);
> >+
> >+	skb->dev = port->dev;
> >+	if (unlikely(netpoll_tx_running(team->dev))) {
> >+		team_netpoll_send_skb(port, skb);
> >+		return 0;
> >+	}
> >+	return dev_queue_xmit(skb);
> >+}
> >+
> 
> Is there any particular reason for moving the whole function?

In the changelog I mentioned:

"For team_dev_queue_xmit() we have to move it down to avoid
compile errors."

Or you mean this isn't clear? As I changed 'port->dev' to 'team->dev',
so the definition of 'struct team' has to be visual to
team_dev_queue_xmit(), therefore I moved to down after that definition.

Thanks!
