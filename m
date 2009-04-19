From: David Miller <davem@davemloft.net>
Subject: Re: What is lock_sock() before skb_free_datagram() for?
Date: Sat, 18 Apr 2009 21:28:42 -0700 (PDT)
Message-ID: <20090418.212842.163717535.davem@davemloft.net>
References: <200904181804.AHC13042.VHFFOOJOFLSQMt@I-love.SAKURA.ne.jp>
	<20090418.020837.106276006.davem@davemloft.net>
	<200904182123.HFF13509.MVSJtQHFLFOFOO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50839
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750777AbZDSE2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2009 00:28:50 -0400
In-Reply-To: <200904182123.HFF13509.MVSJtQHFLFOFOO@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 18 Apr 2009 21:23:35 +0900

> David Miller wrote:
>> > If it is harmful to call lock_sock() for protocols which don't
>> > support global socket memory accounting, I need to make
>> > lock_sock(sk);/release_ sock(sk); calls conditional.
>> 
>> Great, more complexity in the kernel for the sake of TOMOYO
>> :-(
>> 
> You meant that I should leave lock_sock(sk);/release_sock(sk); calls
> unconditional?
> This error path is not frequently called. If there are no problems but
> performance, I'll leave them unconditional.

I mean you should not make generic so no longer generic.

We worked so hard to split out this common code, it is simply
a non-starter for anyone to start putting protocol specific test
into here, or even worse to move this code back to being locally
copied into every protocol implementation.

You may want to think about how you can achieve your goals by putting
these unpleasant hooks into some other location.
