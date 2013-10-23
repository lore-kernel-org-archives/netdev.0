From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fix rtnl notification in atomic context
Date: Wed, 23 Oct 2013 17:09:19 -0400 (EDT)
Message-ID: <20131023.170919.2254167416151180538.davem@davemloft.net>
References: <1382553161-3498-1-git-send-email-ast@plumgrid.com>
	<20131023140343.4604d80d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, nicolas.dichtel@6wind.com, amwang@redhat.com,
	netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab3JWVJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 17:09:21 -0400
In-Reply-To: <20131023140343.4604d80d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 23 Oct 2013 14:03:43 -0700

> On Wed, 23 Oct 2013 11:32:41 -0700
> Alexei Starovoitov <ast@plumgrid.com> wrote:
> 
>> +
>> +void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change)
>> +{
>> +	__rtmsg_ifinfo(type, dev, change, GFP_KERNEL);
>> +}
>>  EXPORT_SYMBOL(rtmsg_ifinfo);
>>  
>>  static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
>> -- 
> 
> Why add another wrapper function? I think it cleaner to just change all the
> callers to use the correct gfp flags.

Indeed, if this were targetted to "net" we'd have the argument of trying
to simplify the patch for -stable inclusion.

But since this is going into net-next, let's just put explicit GFP_* args
at the call site.
