From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next v5 3/3] igmp: convert RTNL lock to a spinlock
Date: Sat, 15 Jun 2013 01:26:08 -0700
Message-ID: <1371284768.3252.151.camel@edumazet-glaptop>
References: <1371282069-26893-1-git-send-email-amwang@redhat.com>
	 <1371282069-26893-3-git-send-email-amwang@redhat.com>
	 <1371282946.3252.148.camel@edumazet-glaptop> <1371283942.23997.8.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:56928 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851Ab3FOI0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jun 2013 04:26:13 -0400
Received: by mail-ee0-f51.google.com with SMTP id e52so781239eek.24
        for <netdev@vger.kernel.org>; Sat, 15 Jun 2013 01:26:11 -0700 (PDT)
In-Reply-To: <1371283942.23997.8.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-15 at 16:12 +0800, Cong Wang wrote:

> I _did_ try to replace spinlock with mutex, but apparently mutex_lock()
> can't be called with rcu_read_lock() held, which is the case in
> ip_mc_drop_socket().
> 

If you hold a mutex, there is no need for rcu_read_lock() at all.

Nobody can change the lists while you are the owner.

We already have nice helpers, lockdep enabled.

check rtnl_dereference() uses
