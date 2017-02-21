From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ip: fix IP_CHECKSUM handling
Date: Tue, 21 Feb 2017 12:26:26 -0500 (EST)
Message-ID: <20170221.122626.706529426465404504.davem@davemloft.net>
References: <3274d7c98d7d5ea07058d8b73f987fc60b6e8b6c.1487612303.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com, edumazet@google.com,
        tom@herbertland.com, stephen@networkplumber.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55378 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753782AbdBUR0e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 12:26:34 -0500
In-Reply-To: <3274d7c98d7d5ea07058d8b73f987fc60b6e8b6c.1487612303.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 21 Feb 2017 09:33:18 +0100

> The skbs processed by ip_cmsg_recv() are not guaranteed to
> be linear e.g. when sending UDP packets over loopback with
> MSGMORE.
> Using csum_partial() on [potentially] the whole skb len
> is dangerous; instead be on the safe side and use skb_checksum().
> 
> Thanks to syzkaller team to detect the issue and provide the
> reproducer.
> 
> v1 -> v2:
>  - move the variable declaration in a tighter scope
> 
> Fixes: ad6f939ab193 ("ip: Add offset parameter to ip_cmsg_recv")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied and queued up for -stable, thanks.
