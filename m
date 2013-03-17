From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: Mask the rta_type when range checking
Date: Sun, 17 Mar 2013 11:44:49 -0400 (EDT)
Message-ID: <20130317.114449.191991112324521259.davem@davemloft.net>
References: <20130314212821.GC25591@casper.infradead.org>
	<51426BB6.5030204@redhat.com>
	<20130315085124.GA17498@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45555 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756337Ab3CQPov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 11:44:51 -0400
In-Reply-To: <20130315085124.GA17498@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 15 Mar 2013 08:51:24 +0000

> On 03/14/13 at 08:30pm, Vlad Yasevich wrote:
>> Doing a quick check on all the callers for rtnl_register and their
>> handlers the following do not use nla_parse:
>>  1) dn_fib_rtm_newroute/delroute  - Don't seem to care about attribute
>>                                     types.
>>  2) dn_cache_getroute() - suspect use.  relies on rta_buf populated by
>>                           rtnetlink_rcv_msg
>> 
>>  3) inet_rtm_newroute/delroute - rtm_to_fib_config() uses a custom loop
>>                                   with nla_type(), so safe.
>> 
>> That's all that a quick look finds.  Out of all of them, looks like
>> on dn_cache_getroute() would be broken.
> 
> So checking values in rta_max[] which lists the maximum attribute
> allowed for each message family range, all are limited to low
> values so the NLA_F_NESTED bit is guaranteed to have been unused
> up to now.
> 
> The risk that remains is that we would start accepting an attribute
> which we previously didn't but we have that risk with every new
> attribute that is added.
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>

Applied and queued up for -stable.  And also agreed that abstracting the
rtnetlink attribute parsing out properly is the way to go.
