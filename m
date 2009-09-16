From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix CONFIG_TCP_MD5SIG + CONFIG_PREEMPT timer BUG()
Date: Tue, 15 Sep 2009 23:49:42 -0700 (PDT)
Message-ID: <20090915.234942.49864006.davem@davemloft.net>
References: <20090915230126.GA21539@hq.alert.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nite@hq.alert.sk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40200
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755213AbZIPGtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 02:49:25 -0400
In-Reply-To: <20090915230126.GA21539@hq.alert.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Varga <nite@hq.alert.sk>
Date: Wed, 16 Sep 2009 01:01:26 +0200

> Hi,
> 
> I have recently came across a preemption imbalance detected by:
> 
> <4>huh, entered ffffffff80644630 with preempt_count 00000102, exited with 00000101?
> <0>------------[ cut here ]------------
> <2>kernel BUG at /usr/src/linux/kernel/timer.c:664!
> <0>invalid opcode: 0000 [1] PREEMPT SMP
> 
> with ffffffff80644630 being inet_twdr_hangman().
> 
> This appeared after I enabled CONFIG_TCP_MD5SIG and played with it a
> bit, so I looked at what might have caused it.
> 
> One thing that struck me as strange is tcp_twsk_destructor(), as it
> calls tcp_put_md5sig_pool() -- which entails a put_cpu(), causing the
> detected imbalance. Found on 2.6.23.9, but 2.6.31 is affected as well,
> as far as I can tell.
> 
> Signed-off-by: Robert Varga <nite@hq.alert.sk>

Looks good, applied and queued up for stable.

Thanks!
