From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netns: Don't receive new packets in a dead network namespace.
Date: Fri, 20 Jun 2008 18:54:02 -0700
Message-ID: <m17icjeeo5.fsf@frodo.ebiederm.org>
References: <20080620204943.GA5068@martell.zuzino.mipt.ru>
	<m1k5gjej5q.fsf@frodo.ebiederm.org>
	<20080621005125.GA5711@martell.zuzino.mipt.ru>
	<20080621012621.GA5035@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:32818 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbYFUCBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 22:01:14 -0400
In-Reply-To: <20080621012621.GA5035@martell.zuzino.mipt.ru> (Alexey Dobriyan's
	message of "Sat, 21 Jun 2008 05:26:21 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan <adobriyan@gmail.com> writes:

> On Sat, Jun 21, 2008 at 04:51:25AM +0400, Alexey Dobriyan wrote:
>> On Fri, Jun 20, 2008 at 05:17:05PM -0700, Eric W. Biederman wrote:
>> > --- a/include/net/net_namespace.h
>> > +++ b/include/net/net_namespace.h
>> > @@ -95,6 +95,11 @@ extern struct list_head net_namespace_list;
>> >  #ifdef CONFIG_NET_NS
>> >  extern void __put_net(struct net *net);
>> >  
>> > +static inline int net_alive(struct net *net)
>> > +{
>> > +	return net && atomic_read(&net->count);
>> > +}
>> 
>> netns pointers are always valid, right?

I think they should be.  Given that net_alive is designed
to be called when the invariants aren't as they should be
I was just paranoid when I wrote it.

> Patch seems to help, BTW.

Thanks.  It fixed the problem for me after I reproduced it.

Eric

