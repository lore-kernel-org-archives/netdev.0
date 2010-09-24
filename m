From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v3] net: af_packet: don't call tpacket_destruct_skb()
	until the skb is sent out
Date: Fri, 24 Sep 2010 06:36:23 +0000
Message-ID: <20100924063623.GA6359@ff.dom.local>
References: <1285236939-3239-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38990 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829Ab0IXGgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 02:36:31 -0400
Received: by bwz11 with SMTP id 11so1785708bwz.19
        for <netdev@vger.kernel.org>; Thu, 23 Sep 2010 23:36:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1285236939-3239-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-23 12:15, Changli Gao wrote:
> Since skb->destructor() is used to account socket memory, and maybe called
> before the skb is sent out, a corrupt skb maybe sent out finally.
> 
> A new destructor is added into structure skb_shared_info(), and it won't
> be called until the last reference to the data of an skb is put. af_packet
> uses this destructor instead.

IMHO, we shouldn't allow for fixing the bad design of one protocol at
the expense of others by adding more and more conditionals. The proper
way of handling paged skbs (splice compatible) exists. And the current
patch doesn't even fix the problem completely against things like
pskb_expand_head or pskb_copy.

af_packet could check some flag which guarantees the queued dev can do
skb_orphan after the real xmit and copy buffers otherwise.

Jarek P.
