From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv4: fib: check forwarding before checking
 send_redirects
Date: Tue, 08 Apr 2014 17:23:43 -0400 (EDT)
Message-ID: <20140408.172343.917107273854891906.davem@davemloft.net>
References: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140408.164356.557108616710530006.davem@davemloft.net>
	<CAM_iQpXrmRNhQCWjiRSKwzxvtcq9XuT-cWS4vRxYVYxpUEN3qQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, ja@ssi.bg,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756121AbaDHVXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 17:23:45 -0400
In-Reply-To: <CAM_iQpXrmRNhQCWjiRSKwzxvtcq9XuT-cWS4vRxYVYxpUEN3qQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 8 Apr 2014 14:17:08 -0700

> We are not supposed even to execute __fib_validate_source() in such
> case, are we? :)

Yes, we used to, every time we'd make a routing cache entry, we'd
execute this code.

Check fib_validate_source() from before the routing cache removal if
you don't believe me.

That check you are editing was added by myself as an optimization
that was necessary after the routing cache removal since this
function performs two FIB table lookups every time it is called.
