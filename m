From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] af_unix: move unix_mknod() out of bindlock
Date: Tue, 24 Jan 2017 14:31:39 -0500 (EST)
Message-ID: <20170124.143139.2126878937432738946.davem@davemloft.net>
References: <1485199055-2342-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com,
        rweikusat@mobileactivedefense.com, viro@zeniv.linux.org.uk
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdAXTbl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 14:31:41 -0500
In-Reply-To: <1485199055-2342-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 23 Jan 2017 11:17:35 -0800

> Dmitry reported a deadlock scenario:
> 
> unix_bind() path:
> u->bindlock ==> sb_writer
> 
> do_splice() path:
> sb_writer ==> pipe->mutex ==> u->bindlock
> 
> In the unix_bind() code path, unix_mknod() does not have to
> be done with u->bindlock held, since it is a pure fs operation,
> so we can just move unix_mknod() out.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Tested-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
