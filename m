From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] decnet: RCU conversion and get rid of dev_base_lock
Date: Mon, 08 Nov 2010 13:43:51 -0800 (PST)
Message-ID: <20101108.134351.229750082.davem@davemloft.net>
References: <1288357764.2560.33.camel@edumazet-laptop>
	<1288360479.9016.35.camel@dolmen>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: steve@chygwyn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57759
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755432Ab0KHVn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 16:43:27 -0500
In-Reply-To: <1288360479.9016.35.camel@dolmen>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Whitehouse <steve@chygwyn.com>
Date: Fri, 29 Oct 2010 14:54:39 +0100

> Hi,
> 
> On Fri, 2010-10-29 at 15:09 +0200, Eric Dumazet wrote:
>> While tracking dev_base_lock users, I found decnet used it in
>> dnet_select_source(), but for a wrong purpose:
>> 
>> Writers only hold RTNL, not dev_base_lock, so readers must use RCU if
>> they cannot use RTNL.
>> 
>> Adds an rcu_head in struct dn_ifaddr and handle proper RCU management.
>> 
>> Adds __rcu annotation in dn_route as well.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> I've not tested this, but I've read through it all and it seems good to
> me.
> 
> Acked-by: Steven Whitehouse <swhiteho@redhat.com>

Applied.
