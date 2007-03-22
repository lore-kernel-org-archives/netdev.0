From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1][PKT_CLS] Avoid multiple tree locks
Date: Thu, 22 Mar 2007 12:36:17 +0100
Message-ID: <46026A31.1090603@trash.net>
References: <1174471116.16343.10.camel@localhost>	 <4601047A.6050108@trash.net> <46010641.3000009@trash.net>	 <4601268D.7090003@trash.net>  <46013B73.2060804@trash.net> <1174543640.4895.28.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33601 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030463AbXCVLgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 07:36:20 -0400
In-Reply-To: <1174543640.4895.28.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-21-03 at 15:04 +0100, Patrick McHardy wrote:
> 
>>These (compile tested) patches demonstrate the idea. 
>>
>>The first one
>>lets netlink_kernel_create users specify a mutex that should be
>>held during dump callbacks, the second one uses this for rtnetlink
>>and changes inet_dump_ifaddr for demonstration.
>>
>>A complete patch would allow us to simplify locking in lots of
>>spots, all rtnetlink users currently need to implement extra
>>locking just for the dump functions, and a number of them
>>already get it wrong and seem to rely on the rtnl.
>>
> 
> 
> The mutex is certainly a cleaner approach;
> and a lot of the RCU protection would go away. I like it.


Not as much as I initially thought, but at least we would have
consistent locking for the dump callbacks.

> Knowing you i sense theres something clever in there that i am 
> missing. I dont see how you could get rid of the tree locking
> since we need to protect against the data path still, no?
> Or are you looking at that as a separate effort?


We can remove qdisc_tree_lock since with this patch all changes
and all tree walking happen under the RTNL. We still need to keep
dev->queue_lock for the data path.

I'll update the patches to include all rtnetlink users and repost
in a day or two.
