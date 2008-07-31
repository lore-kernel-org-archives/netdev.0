From: David Miller <davem@davemloft.net>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
 __netif_schedule+0x2c/0x98()
Date: Thu, 31 Jul 2008 05:44:01 -0700 (PDT)
Message-ID: <20080731.054401.06991829.davem@davemloft.net>
References: <20080727203757.GA2527@ami.dom.local>
	<20080731.052932.110299354.davem@davemloft.net>
	<200807312238.20264.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, johannes@sipsolutions.net, netdev@axxeo.de,
	peterz@infradead.org, Larry.Finger@lwfinger.net, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, mingo@redhat.com
To: nickpiggin@yahoo.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51934
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750902AbYGaMoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 08:44:01 -0400
In-Reply-To: <200807312238.20264.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 31 Jul 2008 22:38:19 +1000

> Except for the braindead volatile that gets stuck on the bitops pointer.
> 
> Last time I complained about this, a lot of noise was made and I think
> Linus wanted it to stay around so we could pass volatile pointers to
> bitops & co without warnings. I say we should just remove the volatile
> and kill any callers that might warn...

Ho hum... :)

Another way to approach that, and keep the volatile, is to have
a "test_flags()" interface that takes the bit mask of values
you want to test for cases where you know it is a single word
flags value.

The downside is that this kind of interface is easy to use
incorrectly especially when accesses to the same flags use
bot test_bit() and test_flags().
