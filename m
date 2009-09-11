From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] bonding: remap muticast addresses without using
 dev_close() and dev_open()
Date: Fri, 11 Sep 2009 12:36:52 -0700 (PDT)
Message-ID: <20090911.123652.92869438.davem@davemloft.net>
References: <4AA39E42.9070702@Voltaire.COM>
	<4AA8B19F.2080704@voltaire.com>
	<4AA8BD09.2010607@Voltaire.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@voltaire.com, fubar@us.ibm.com,
	jgunthorpe@obsidianresearch.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: monis@Voltaire.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57528
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752202AbZIKTgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 15:36:36 -0400
In-Reply-To: <4AA8BD09.2010607@Voltaire.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@Voltaire.COM>
Date: Thu, 10 Sep 2009 11:47:05 +0300

> I don't need to revert the entire patch. Only the dev_open() and
> dev_close() functions need to be removed and it is quite easy to
> review it in one patch.

I agree, this is the best way to submit this.

> I thought about it but the function arp_mc_map() which is called
> before and after the change in dev->type, relies on the value of
> dev->type. I could write the patch with one event after the type has
> changed and passing the old device type somehow (field prev_type in
> struct net_device?) but the resulted code will look clumsy (at least
> to me).

That's correct, dev->type must be setup correctly to both undo
and install things properly so this approach is correct.

But unfortunately this patch doesn't apply to net-next-2.6 and
you'll need to respin it against current sources so I can apply
it, thanks.
