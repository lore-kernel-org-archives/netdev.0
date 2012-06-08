From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: Fix corrupted queue_mapping
Date: Fri, 08 Jun 2012 09:46:37 +0200
Message-ID: <1339141597.6001.47.camel@edumazet-glaptop>
References: <1339135057.6001.20.camel@edumazet-glaptop>
	 <20120607.230216.2014005732863772019.davem@davemloft.net>
	 <1339135881.6001.25.camel@edumazet-glaptop>
	 <20120607.231501.463746858434969001.davem@davemloft.net>
	 <1339138040.6001.39.camel@edumazet-glaptop>
	 <1339140238.6001.42.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54295 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755349Ab2FHHqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 03:46:42 -0400
Received: by eeit10 with SMTP id t10so849933eei.19
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 00:46:41 -0700 (PDT)
In-Reply-To: <1339140238.6001.42.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-08 at 09:24 +0200, Eric Dumazet wrote:

> 
> I must say I dont understand dev_pick_tx() anymore.
> 
> It seems to ignore skb->queue_mapping (unless device provides its own
> ndo_select_queue() and this functions is aware of skb->queue_mapping, as
> correctly done in ixgbe)
> 
> So commit fff3269907897ee (tcp: reflect SYN queue_mapping into SYNACK
> packets) works on ixgbe, but probably not on other multiqueue devices.
> 
> This sounds like a regression to me.

Oh well, its done in skb_tx_hash(), after a few indirections, and if
skb->sk is NULL.

Which happens to be true in net-next for SYNACKS after commit
90ba9b1986b5ac (tcp: tcp_make_synack() can use alloc_skb())
