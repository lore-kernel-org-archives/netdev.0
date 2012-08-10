From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 09/14] netpoll: check netpoll tx status on the right
 device
Date: Fri, 10 Aug 2012 10:32:54 +0200
Message-ID: <20120810083254.GB1543@minipsycho>
References: <1344582637-18261-1-git-send-email-amwang@redhat.com>
 <1344582637-18261-10-git-send-email-amwang@redhat.com>
 <20120810072018.GA1543@minipsycho>
 <1344585156.29601.4.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:50172 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767Ab2HJIc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 04:32:58 -0400
Received: by wicr5 with SMTP id r5so241588wic.1
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 01:32:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1344585156.29601.4.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 10, 2012 at 09:52:36AM CEST, amwang@redhat.com wrote:
>On Fri, 2012-08-10 at 09:20 +0200, Jiri Pirko wrote:
>> > 
>> >+static inline int team_dev_queue_xmit(struct team *team, struct team_port *port,
>> >+				      struct sk_buff *skb)
>> >+{
>> >+	BUILD_BUG_ON(sizeof(skb->queue_mapping) !=
>> >+		     sizeof(qdisc_skb_cb(skb)->slave_dev_queue_mapping));
>> >+	skb_set_queue_mapping(skb, qdisc_skb_cb(skb)->slave_dev_queue_mapping);
>> >+
>> >+	skb->dev = port->dev;
>> >+	if (unlikely(netpoll_tx_running(team->dev))) {
>> >+		team_netpoll_send_skb(port, skb);
>> >+		return 0;
>> >+	}
>> >+	return dev_queue_xmit(skb);
>> >+}
>> >+
>> 
>> Is there any particular reason for moving the whole function?
>
>In the changelog I mentioned:
>
>"For team_dev_queue_xmit() we have to move it down to avoid
>compile errors."
>
>Or you mean this isn't clear? As I changed 'port->dev' to 'team->dev',
>so the definition of 'struct team' has to be visual to
>team_dev_queue_xmit(), therefore I moved to down after that definition.

Right. Thanks!

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
