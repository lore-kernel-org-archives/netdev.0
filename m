From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 1/2] rtnetlink: add new RTM_GETSTATS message
 to query stats
Date: Sat, 16 Apr 2016 18:50:16 -0700
Message-ID: <5712EBD8.2060100@cumulusnetworks.com>
References: <1460777293-39474-2-git-send-email-roopa@cumulusnetworks.com> <20160416074910.GA2486@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34321 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbcDQBuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 21:50:19 -0400
Received: by mail-pf0-f171.google.com with SMTP id c20so68838369pfc.1
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 18:50:19 -0700 (PDT)
In-Reply-To: <20160416074910.GA2486@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/16/16, 12:49 AM, Thomas Graf wrote:
> On 04/15/16 at 08:28pm, Roopa Prabhu wrote:
>> +static u16 rtnl_stats_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
>> +{
>> +	struct net *net = sock_net(skb->sk);
>> +	struct net_device *dev;
>> +	u16 min_ifinfo_dump_size = 0;
>> +	struct if_stats_msg *ifsm;
>> +	u32 filter_mask;
>> +
>> +	ifsm = nlmsg_data(nlh);
>> +	filter_mask = ifsm->filter_mask;
>> +
>> +	/* traverse the list of net devices and compute the minimum
>> +	 * buffer size based upon the filter mask.
>> +	 */
>> +	list_for_each_entry(dev, &net->dev_base_head, dev_list) {
>> +		min_ifinfo_dump_size = max_t(u16, min_ifinfo_dump_size,
>> +					     if_nlmsg_stats_size(dev,
>> +								 filter_mask));
>> +	}
> Iterating over all net_devices in the namespace is quite an expensive
> operation and it would now be done twice.
>
> I understand that this code is taken over from rtnl_calcit() but there
> the cost is at least only paid if ext_filter_mask is actually set and
> the user opts into additional statistics.
>
> I wonder if we can reduce the cost for the stats interface as its
> purpose is to be minimal cost. I suggest we only add the loop once we
> have an extension which actually depends on it. We can then try and
> figure out to not require it.
ok, ack. Its not absolutely necessary right now with the one link filter stats
I am adding support for. We can bring it back later when we see a first instance
 which makes it necessary.

In which case, I am going to trim down the series to absolute minimal.
just rtnl link stats64. I want to drop the ipv6 patch anyways.
With it I will also drop the general af stats handling. Will get it back when we get to the first
proper af stats implementation (hopefully mpls).

With this, the calcit for RTM_GETSTATS will be NULL, until we add the implementation for the other
stats attributes.
