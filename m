From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ] ipv6: handle the update of the NDISC_REDIRECT error
 code in icmpv6_err_convert
Date: Wed, 18 Sep 2013 12:36:13 -0400 (EDT)
Message-ID: <20130918.123613.61436246160249555.davem@davemloft.net>
References: <523996E0.9080702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612Ab3IRQgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 12:36:15 -0400
In-Reply-To: <523996E0.9080702@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Wed, 18 Sep 2013 20:04:48 +0800

> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> when dealing with redirect message in udpv6_err() and
> rawv6_err() the err shoud be assigned to 0, not EPROTO.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

No, you should fix this the same way you handled DCCP, but skipping
the whole socket error setting path for NDISC_REDIRECT.

Clearing the socket error to zero is not correct, it means you will
lose any existing error setting.
