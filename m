From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1][PKT_CLS] Avoid multiple tree locks
Date: Wed, 21 Mar 2007 13:35:25 +0100
Message-ID: <4601268D.7090003@trash.net>
References: <1174471116.16343.10.camel@localhost> <4601047A.6050108@trash.net> <46010641.3000009@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41733 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbXCUMfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 08:35:32 -0400
In-Reply-To: <46010641.3000009@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
>>Its harmless since its a read lock, which can be nested. I actually
>>don't see any need for qdisc_tree_lock at all, all changes and all
>>walking is done under the RTNL, which is why I've removed it in
>>my (upcoming) patches. I suggest to leave it as is for now so I
>>don't need to change the __qdisc_lookup back to qdisc_lookup in
>>2.6.22.
> 
> 
> 
> Alexey just explained to me why we do need qdisc_tree_lock in private
> mail. While dumping only the first skb is filled under the RTNL,
> while filling further skbs we don't hold the RTNL anymore. So I will
> probably have to drop that patch.


What we could do is replace the netlink cb_lock spinlock by a
user-supplied mutex (supplied to netlink_kernel_create, rtnl_mutex
in this case). That would put the entire dump under the rtnl and
allow us to get rid of qdisc_tree_lock and avoid the need to take
dev_base_lock during qdisc dumping. Same in other spots like
rtnl_dump_ifinfo, inet_dump_ifaddr, ...

What do you think?
