From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH][NETNS] Make ifindex generation per-namespace
Date: Thu, 11 Oct 2007 11:22:57 -0600
Message-ID: <m1hckxbm6m.fsf@ebiederm.dsl.xmission.com>
References: <470B71CD.3000706@openvz.org>
	<m1przoxk1v.fsf@ebiederm.dsl.xmission.com>
	<1192041243.4770.8.camel@johannes.berg>
	<m1wstukasp.fsf@ebiederm.dsl.xmission.com>
	<1192095150.4770.25.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:39122 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755267AbXJKRYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 13:24:16 -0400
In-Reply-To: <1192095150.4770.25.camel@johannes.berg> (Johannes Berg's message
	of "Thu, 11 Oct 2007 11:32:30 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes@sipsolutions.net> writes:

> On Wed, 2007-10-10 at 13:51 -0600, Eric W. Biederman wrote:
>
>> Yes.  Netlink sockets are per-namespace and you can use the namespace
>> of a netlink socket to look up a netdev.
>
> Ok, thanks. I still haven't really looked into the wireless vs. net
> namespaces problem but this will probably help.

I think I may even have some patches in my proof of concept tree that
address some of the wireless issues.  Especially rtnetlink ones.
Generally those cases haven't been hard to spot.

Having hash tables and the like that hash and do key compares
on an ifindex instead of a net_device * are the in kernel places that
make it very hard to have duplicate ifindexes.

Thinking about it probably the biggest challenge to deal with
is iff in struct sk_buff.

Eric
