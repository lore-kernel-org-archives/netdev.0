From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 01/54] uml/net_kern: Call dev_consume_skb_any instead of
 dev_kfree_skb.
Date: Wed, 26 Mar 2014 09:49:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E93E1@AcuExch.aculab.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	<1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	<1395752472.12610.108.camel@edumazet-glaptop2.roam.corp.google.com>
 <87fvm6cfxh.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
	"mpm@selenic.com" <mpm@selenic.com>,
	"satyam.sharma@gmail.com" <satyam.sharma@gmail.com>
To: "'Eric W. Biederman'" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39460 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751054AbaCZJuX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 05:50:23 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13499-10 for <netdev@vger.kernel.org>;
 Wed, 26 Mar 2014 09:50:20 +0000 (GMT)
In-Reply-To: <87fvm6cfxh.fsf@x220.int.ebiederm.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Eric W. Biederman
...
> I really don't think using enum skb_free_reason makes any sense
> whatsoever.  Not in the implementation of dev_kfree_skb_any and
> dev_kfree_skb_irq and certainly not in a driver.  What
> net/core/drop_monitor.c wants is the address of the function where drops
> occur (so we can track down and debug why the kernel is dropping
> packets) and the existing implementation of dev_kfree_skb_any and
> dev_kfree_skb_irq loose that information.  The use of enum
> skb_free_reason is a big part of the reason why we loose that
> information.  (We should be using a (void *) so that we can capture
> __builtin_return_address(0) instead...

Maybe more useful to allow a literal string be given.
Easier to find in the source tree than the return address.

Or (OTT) create a linkset data item containing info about the
call site and a counter....

	David
