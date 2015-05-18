From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 0/3] tc state machinery cleanups
Date: Sun, 17 May 2015 23:34:05 -0400 (EDT)
Message-ID: <20150517.233405.601002797695700706.davem@davemloft.net>
References: <1431679850-31896-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbbERDeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 23:34:09 -0400
In-Reply-To: <1431679850-31896-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 15 May 2015 10:50:47 +0200

> This series prepares removal of tc_verd member from sk_buff.
> 
> It simplifies tc state machinery to what is required to keep current
> mirred/ifb combinations working.
> 
> I tested a few scenarios, namely:
> 
> 1 - htb based shaping on egress
> 2 - netem attached to ifb with mirred redirect from ingress qdisc
> 3 - mirred to different egress device
> 4 - mirred to ifb egress device with qdiscs set up on ifb
>     to provide illusion of 'single' transmit interface for traffic shaping
> 
> After this series tc_verd is only used by ifb to skip actions on egress.
> 
> Part #2 of this series will remove tc_verd completely.
> 
> motivation is two-fold:
> 1) make states and state transitions more obvious
> 2) provide a way to later reduce skb size by 8 bytes
>    (s/u16 mac_len/u8 mac_len/ would result in
>     two 2 byte and one 4 byte hole, i.e. 8 byte reduction with
>     minor reshuffling).

It looks like there will be changes to this series.

My only comment from my perspective is that, in patch #1, you
should probably add a "TC_FROM_UNKNOWN = 0" to the enumeration
and test/set using that instead of a magic constant.

Thanks.
