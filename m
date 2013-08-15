From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: restore "linklayer atm" handling
Date: Thu, 15 Aug 2013 01:43:23 -0700 (PDT)
Message-ID: <20130815.014323.887178976013533551.davem@davemloft.net>
References: <20130814214711.23885.76734.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave.taht@gmail.com, netdev@vger.kernel.org, shemminger@vyatta.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab3HOInZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 04:43:25 -0400
In-Reply-To: <20130814214711.23885.76734.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 14 Aug 2013 23:47:11 +0200

> commit 56b765b79 ("htb: improved accuracy at high rates")
> broke the "linklayer atm" handling.
> 
>  tc class add ... htb rate X ceil Y linklayer atm
> 
> The linklayer setting is implemented by modifying the rate table
> which is send to the kernel.  No direct parameter were
> transferred to the kernel indicating the linklayer setting.
> 
> The commit 56b765b79 ("htb: improved accuracy at high rates")
> removed the use of the rate table system.
> 
> To keep compatible with older iproute2 utils, this patch detects
> the linklayer by parsing the rate table.  It also supports future
> versions of iproute2 to send this linklayer parameter to the
> kernel directly. This is done by using the __reserved field in
> struct tc_ratespec, to convey the choosen linklayer option, but
> only using the lower 4 bits of this field.
> 
> Linklayer detection is limited to speeds below 100Mbit/s, because
> at high rates the rtab is gets too inaccurate, so bad that
> several fields contain the same values, this resembling the ATM
> detect.  Fields even start to contain "0" time to send, e.g. at
> 1000Mbit/s sending a 96 bytes packet cost "0", thus the rtab have
> been more broken than we first realized.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, thanks.
