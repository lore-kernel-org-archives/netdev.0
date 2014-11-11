From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 net-next 1/2] bonding: Expand speed type bits of the
 AD Port Key
Date: Tue, 11 Nov 2014 13:53:05 -0500 (EST)
Message-ID: <20141111.135305.1647707440180670390.davem@davemloft.net>
References: <1415603801-21285-1-git-send-email-Jianhua.Xie@freescale.com>
	<1415603801-21285-2-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net
To: Jianhua.Xie@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbaKKSxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 13:53:08 -0500
In-Reply-To: <1415603801-21285-2-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xie Jianhua <Jianhua.Xie@freescale.com>
Date: Mon, 10 Nov 2014 15:16:40 +0800

> From: Jianhua Xie <Jianhua.Xie@freescale.com>
> 
> Port Key was determined as 16 bits according to the link speed,
> duplex and user key (which is yet not supported), in which key
> speed was 5 bits for 1Mbps/10Mbps/100Mbps/1Gbps/10Gbps as below:
> --------------------------------------------------------------
> Port key :|	User key	| Speed		|	Duplex|
> --------------------------------------------------------------
> 16			6		1		0
> This patch is expanding speed type from 5 bits to 9 bits for other
> speed 2.5Gbps/20Gbps/40Gbps/56Gbps and shrinking user key from 10
> bits to 6 bits.  New Port Key looks like below:
> --------------------------------------------------------------
> Port key :|	User key	| Speed		|	Duplex|
> --------------------------------------------------------------
> 16			10		1		0
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: David S. Miller <davem@davemloft.net>
> 
> Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>

Do we determine the layout of this value all ourselves?

If not, then is it exported to anything user-visible that we
might be breaking?

If it is private, it makes no sense to use a bitmask for the speed.
We should instead change the field to be some numerically increasing
value.

Otherwise we'll run out of bits again and keep having to adjust the
field layout more often than we really need to.
