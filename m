From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix possible NULL dereference in icmp6_dst_alloc
Date: Wed, 27 Jan 2010 05:14:10 -0800 (PST)
Message-ID: <20100127.051410.74328462.davem@davemloft.net>
References: <20100127121746.GA15611@ff.dom.local>
	<20100127.042336.52877358.davem@davemloft.net>
	<20100127124331.GB15611@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, djohnson@starentnetworks.com,
	sakkiped@starentnetworks.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33942
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752658Ab0A0NN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 08:13:58 -0500
In-Reply-To: <20100127124331.GB15611@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 27 Jan 2010 12:43:31 +0000

> I'm only not sure there is a better way (comments?) to make this
> code readable.

You can make it more readable and even validate the invariant at the
same time by adding some kind of inline function if you wish.

static inline struct dst_entry *rtable_to_dst_entry(struct rtable *rt)
{
	BUILD_BUG_ON(rt != &rt->u.dst);

	/* Because "->u.dst" is the first member of struct rtable,
	 * this dereference is safe even when rt is NULL.
	 */
	return &rt->u.dst;
}

Something like that.
