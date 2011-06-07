From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: prevent information leak
Date: Mon, 06 Jun 2011 22:24:16 -0700 (PDT)
Message-ID: <20110606.222416.1114593259198630297.davem@davemloft.net>
References: <1307422939.2642.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab1FGFZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 01:25:29 -0400
In-Reply-To: <1307422939.2642.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Jun 2011 07:02:19 +0200

> In 2.6.27, commit 393e52e33c6c2 (packet: deliver VLAN TCI to userspace)
> added a small information leak.
> 
> Add padding field and make sure its zeroed before copy to user.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Patrick McHardy <kaber@trash.net>

I fear this will change the size of these structures on some weird
architecture.  Doesn't ARM, for example, have weird rules
wrt. alignment and structure sizing when "smaller than word" elements
are involved?

That's why we need __packed on:

struct nd_opt_hdr {
	__u8		nd_opt_type;
	__u8		nd_opt_len;
} __packed;

for example.

Probably safe to just do a memset of the tail, and the constant length
will evaluate to zero on these weird platforms.  On others, where the
padding does matter, the memset will emit the same code as your new
assignments do.
