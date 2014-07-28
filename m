From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_tunnel(ipv4): fix tunnels with "local any remote
 $remote_ip"
Date: Mon, 28 Jul 2014 16:44:32 -0700 (PDT)
Message-ID: <20140728.164432.336779387487870757.davem@davemloft.net>
References: <20140729030752.d156e9522754e8a6262541ec@qrator.net>
	<CAHA+R7P3gN6Xd==bF9r=396DBi=sTab7tHgZr4agiLxDBdrk+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ixaphire@qrator.net, netdev@vger.kernel.org, pinkbyte@gentoo.org,
	edumazet@google.com, therbert@google.com
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbaG1Xod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 19:44:33 -0400
In-Reply-To: <CAHA+R7P3gN6Xd==bF9r=396DBi=sTab7tHgZr4agiLxDBdrk+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Mon, 28 Jul 2014 16:39:23 -0700

> On Mon, Jul 28, 2014 at 4:07 PM, Dmitry Popov <ixaphire@qrator.net> wrote:
>> --- a/include/net/ip_tunnels.h
>> +++ b/include/net/ip_tunnels.h
>> @@ -40,6 +40,7 @@ struct ip_tunnel_prl_entry {
>>
>>  struct ip_tunnel_dst {
>>         struct dst_entry __rcu          *dst;
>> +       __be32                           saddr;
>>  };
> 
> 
> It looks odd to save a source address in some struct named dst,
> maybe it's the time to rename it.

It's an encapsulation struct for plain "struct dst_entry", which is a
path to a destination, or in other words a "route".  A "saddr" is a
valid key for a route.

I see no reason to change the name of this structure, it's perfect.
