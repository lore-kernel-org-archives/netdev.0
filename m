From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  BUG: NULL pointer in ctnetlink_conntrack_event
Date: Fri, 29 Jun 2012 20:22:15 +0200 (CEST)
Message-ID: <dri38gk.7565a5f72fad1195f68b28af6833796c@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "Pablo Neira Ayuso" <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw11.han.skanova.net ([81.236.55.20]:47407 "EHLO
	smtp-gw11.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512Ab2F2SWT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 14:22:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>On Fri, Jun 29, 2012 at 02:29:37PM +0200, Hans Schillstrom wrote:
>> Hello,
>> 
>> There is a "hard to find" problem in ctnetlink_conntrack_event() when calling
>> netlink_has_listeners() net->nfnl is NULL.
>> 
>> The rcu stuff seems to be right at a first look but who knows...
>> 
>> The line below fix the problem, but that is not the root cause.
>> 
>>  int nfnetlink_has_listeners(struct net *net, unsigned int group)
>>  {
>> -       return netlink_has_listeners(net->nfnl, group);
>> +       return net->nfnl ? netlink_has_listeners(net->nfnl, group) : 0 ;
>>  }
>> 
>> Yes it is a 3.0.26 kernel but this patch is applied
>> netfilter: nf_conntrack: make event callback registration per-netns
>
>I think this patch above is missing some rcu_access_pointer usage.
>
>Please, see patch attached.

Thanks it looks like it's the missing patch.

/Hans
