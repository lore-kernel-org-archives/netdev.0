From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-next: Fix __inet_inherit_port() to correctly
 increment bsockets and num_owners
Date: Sun, 28 Nov 2010 18:20:06 -0800 (PST)
Message-ID: <20101128.182006.183047625.davem@davemloft.net>
References: <844781.48196.qm@web53701.mail.re2.yahoo.com>
	<20101128230041.GA16269@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomer_iisc@yahoo.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51164
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754246Ab0K2CTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 21:19:40 -0500
In-Reply-To: <20101128230041.GA16269@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Mon, 29 Nov 2010 02:00:41 +0300

> Hi.
> 
> On Fri, Nov 26, 2010 at 04:26:27PM -0800, Nagendra Tomar (tomer_iisc@yahoo.com) wrote:
>> inet sockets corresponding to passive connections are added to the bind hash
>> using ___inet_inherit_port(). These sockets are later removed from the bind 
>> hash using __inet_put_port(). These two functions are not exactly symmetrical. 
>> __inet_put_port() decrements hashinfo->bsockets and tb->num_owners, whereas 
>> ___inet_inherit_port() does not increment them. This results in both of these 
>> going to -ve values.
>> 
>> This patch fixes this by calling inet_bind_hash() from ___inet_inherit_port(),
>> which does the right thing.
>> 
>> 'bsockets' and 'num_owners' were introduced by commit a9d8f9110d7e953c 
>> (inet: Allowing more than 64k connections and heavily optimize bind(0))
> 
> Yup, things changed from that simple patch a lot.
> Thanks for fixing it up.
> Ack.

I've decided to apply this to net-2.6, thanks everyone.
