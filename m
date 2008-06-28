From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Prevent from potential dead lock for inet_listen_lock
Date: Fri, 27 Jun 2008 19:32:34 -0700 (PDT)
Message-ID: <20080627.193234.134186954.davem@davemloft.net>
References: <485B7384.1090204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: guijianfeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46676
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751534AbYF1Cce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 22:32:34 -0400
In-Reply-To: <485B7384.1090204@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Date: Fri, 20 Jun 2008 17:08:20 +0800

> hashinfo->lhash_lock might be acquired by write_lock() in softirq, 

How?

> so using read_lock() here isn't safe, just substitudes by read_lock_bh().
> 
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>

I don't think this is necessary.

The only place the write lock is obtained, is via
the ->hash() and ->unhash() sk_prot operation methods.

And for listening sockets that only occurs in normal base
context.  Never from softirqs.

If there is a patch from softirqs where this can occur,
that is a bug and must be fixed.
