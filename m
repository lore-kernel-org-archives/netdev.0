From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 1/1 v3] drivers: net: rmnet: Initial
 implementation
Date: Mon, 14 Aug 2017 17:52:45 -0600
Message-ID: <a0ec8e95c5c2b84aad176ef523589bc4@codeaurora.org>
References: <1492146329-4304-1-git-send-email-subashab@codeaurora.org>
 <1492146329-4304-2-git-send-email-subashab@codeaurora.org>
 <20170414090752.GA1992@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52662 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752651AbdHNXwq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 19:52:46 -0400
In-Reply-To: <20170414090752.GA1992@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> + */
>> +void rmnet_egress_handler(struct sk_buff *skb,
>> +			  struct rmnet_logical_ep_conf_s *ep)
>> +{
>> +	struct rmnet_phys_ep_conf_s *config;
>> +	struct net_device *orig_dev;
>> +	int rc;
>> +
>> +	orig_dev = skb->dev;
>> +	skb->dev = ep->egress_dev;
>> +
>> +	config = (struct rmnet_phys_ep_conf_s *)
>> +		rcu_dereference(skb->dev->rx_handler_data);
> 
> This is certainly a misuse of dev->rx_handler_data. Dev private of a
> function arg to carry the pointer around.
> 

Hi Jiri

Sorry for the delay in posting a new series.
I have an additional query regarding this comment.

This dev (from skb->dev->rx_handler_data) corresponds to the real_dev to 
which
the rmnet devices are attached to. I had earlier setup a rx_handler on 
this
real_dev netdevice in rmnet_associate_network_device(). Would it still 
be
incorrect to use rx_handler_data of real_dev to have rmnet specific 
config
information?

Bridge is similarly storing the bridge information on the real_dev
rx_handler_data and retrieving it through br_port_get_rcu(). I am using 
that
as a reference.
