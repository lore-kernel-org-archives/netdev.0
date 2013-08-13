From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] net: sctp: sctp_transport_destroy{,_rcu}: fix
 potential pointer corruption
Date: Mon, 12 Aug 2013 22:14:18 -0700 (PDT)
Message-ID: <20130812.221418.587541295527206954.davem@davemloft.net>
References: <1376058321-2461-1-git-send-email-dborkman@redhat.com>
	<5204FFDD.5060703@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34334 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754117Ab3HMFOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 01:14:19 -0400
In-Reply-To: <5204FFDD.5060703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Fri, 09 Aug 2013 10:42:37 -0400

> On 08/09/2013 10:25 AM, Daniel Borkmann wrote:
>> Probably this one is quite unlikely to be triggered, but it's more
>> safe
>> to do the call_rcu() at the end after we have dropped the reference on
>> the asoc and freed sctp packet chunks. The reason why is because in
>> sctp_transport_destroy_rcu() the transport is being kfree()'d, and if
>> we're unlucky enough we could run into corrupted pointers. Probably
>> that's more of theoretical nature, but it's safer to have this simple
>> fix.
>>
>> Introduced by commit 8c98653f ("sctp: sctp_close: fix release of
>> bindings
>> for deferred call_rcu's"). I also did the 8c98653f regression test and
>> it's fine that way.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> 
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied, thanks everyone.
