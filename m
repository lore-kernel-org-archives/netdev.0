From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv4: fib: check forwarding before checking
 send_redirects
Date: Tue, 08 Apr 2014 16:43:56 -0400 (EDT)
Message-ID: <20140408.164356.557108616710530006.davem@davemloft.net>
References: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, ja@ssi.bg,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46556 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932220AbaDHUn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 16:43:58 -0400
In-Reply-To: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  8 Apr 2014 12:31:22 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> We have seen in a weird case we had to disable send_redirects in order
> to pass rp filter check even though we don't set forwarding at all.
> This looks wrong, at least according to ip-sysctl.txt send_redirects should
> only make sense when we enable forwarding.
> 
> Cc: Eric Biederman <ebiederm@xmission.com>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

I'm not so sure about this.

This test here is just an optimization, which bypasses the long path
processing of FIB source address validation if certain strict
conditions are met.

__fib_validate_source() should do the right thing if it is executed,
it is just the slow path, and you should determine why it is rejecting
your traffic instead.

Your change is a valid optimization perhaps, but not a bug fix.
