From: David Miller <davem@davemloft.net>
Subject: Re: [B.A.T.M.A.N.] [PATCH 01/10] batman-adv: fix soft-interface
 MTU computation
Date: Tue, 18 Feb 2014 15:41:52 -0500 (EST)
Message-ID: <20140218.154152.94226033273009453.davem@davemloft.net>
References: <1392670129-2498-2-git-send-email-antonio@meshcoding.com>
	<20140217.161314.741869447870850076.davem@davemloft.net>
	<53030165.2050404@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	mareklindner@neomailbox.ch
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbaBRUlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 15:41:55 -0500
In-Reply-To: <53030165.2050404@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Tue, 18 Feb 2014 07:44:53 +0100

> On 17/02/14 22:13, David Miller wrote:
>> From: Antonio Quartulli <antonio@meshcoding.com>
>> Date: Mon, 17 Feb 2014 21:48:40 +0100
>> 
>>> +	atomic_set(&bat_priv->packet_size_max, min_mtu);
>> 
>> Please fix this.
>> 
>> The only operations performed on packet_size_max are 'set' and
>> 'read'.  This is not what one uses atomic_t's for.
>> 
>> The use of an atomic_t in this context is a NOP.  You aren't
>> getting any kind of synchronization at all.
> 
> True. Thanks for the suggestion.
> Unfortunately this is not the only "fake-atomic" variable we have.

So I pulled this, but I just want you to know that you should really
start to bear down and minimize the amount of changes you are submitting
for 'net' as we're starting to get deep into -rc territory.

Thanks.
