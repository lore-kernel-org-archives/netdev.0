From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 0/4] Support UID range routing.
Date: Fri, 02 May 2014 15:24:41 -0400 (EDT)
Message-ID: <20140502.152441.695810627123047.davem@davemloft.net>
References: <20140428.125807.409036177577836732.davem@davemloft.net>
	<CAKD1Yr1HN4=42JYfe9LYguWukXxNE38vvwLBt-aEeQ-zSisN9Q@mail.gmail.com>
	<CAKD1Yr0wqj0wG3Ges9NeqMBALO-SxY9KTgZo_sp_8VYKnihKMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidn@davidnewall.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org, jpa@google.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbaEBTYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 15:24:42 -0400
In-Reply-To: <CAKD1Yr0wqj0wG3Ges9NeqMBALO-SxY9KTgZo_sp_8VYKnihKMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Sat, 3 May 2014 04:15:38 +0900

> On Tue, Apr 29, 2014 at 4:01 AM, Lorenzo Colitti <lorenzo@google.com> wrote:
>> Basically, what this patch calls "UID" is what the xt_owner module and
>> xt_LOG iptables modules consider to be the "owner" of a socket, what
>> nfqueue presents as the user ID, what shows up in
>> /proc/net/{udp,tcp,raw} in the "uid" column, etc. In most cases this
>> is the effective UID that made the call to socket() or accept().
>>
>> This patch allows using that concept in routing. This can be done
>> today with "iptables -m owner --uid-owner 12345 -j MARK --set-mark
>> 0xbeef; ip rule from fwmark 0xbeef lookup 100", but that has the
>> limitations I set out in my original message (e.g., incorrect source
>> address).
> 
> did that help clarify what I'm proposing here? Does this patch still
> seem misguided to you even though its semantics match existing
> functionality?

I understand what you're trying to achieve, but it still leaves a very
bad taste in my mouth.

And I question whether you absolutely cannot get the desired source
address set with appropriate adjustments to the netfilter config,
netfilter can mangle the packet any way you desire it to so why can't
it do so to the source address?
