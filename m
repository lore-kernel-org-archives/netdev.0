From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] net: remove delay at device dismantle
Date: Thu, 23 Aug 2012 09:00:26 +0200
Message-ID: <1345705226.5904.107.camel@edumazet-glaptop>
References: <1345691986.5904.40.camel@edumazet-glaptop>
	 <87txvum80h.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, gaofeng@cn.fujitsu.com,
	netdev@vger.kernel.org, maheshb@google.com, therbert@google.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38073 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab2HWHAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 03:00:31 -0400
Received: by bkwj10 with SMTP id j10so98635bkw.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 00:00:30 -0700 (PDT)
In-Reply-To: <87txvum80h.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 23:34 -0700, Eric W. Biederman wrote:

> raw_notifier_call_chain isn't safe without holding some sort of lock.
> So removing the ASSERT_RTNL assert here is papering over a bug elsewhere
> in this patch.
> 
> Without holding a lock for traversing the notifier chain there will
> be races with network module load and unload that could corrupt
> this list while we are traversing it.
> load/unlod.
> 
> You already have one of your NETDEV_UNREGISTER_FINAL calls under the
> rtnl_lock so it doesn't look like a burden to put the other call under
> the rtnl_lock as well.

Hmm right, I have been fooled by the rcu_dereference_raw() calls in
notifier_call_chain()

I'll send an update, thanks !
