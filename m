From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Wed, 29 Apr 2009 11:22:40 +0200
Message-ID: <20090429092240.GA30403@elte.hu>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com> <49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org> <49F71B63.8010503@cosmosbay.com> <20090429002049.4bbc8105.akpm@linux-foundation.org> <20090429073539.GR27382@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <dada1@cosmosbay.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, cl@linux.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:55946 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbZD2JXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2009 05:23:53 -0400
Content-Disposition: inline
In-Reply-To: <20090429073539.GR27382@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Andi Kleen <andi@firstfloor.org> wrote:

> > Seems that this is a virtuous patch even though Christoph is struggling
> > a bit to test it?
> 
> The main drawback is that the select/poll data structures will get 
> larger. That could cause regression in theory. [...]

Current size of struct poll_table_entry is 0x38 on 64-bit kernels. 
Adding the key will make it 0x40 - which is not only a power of two 
but also matches cache line size on most modern CPUs.

So the size of this structure is ideal now and arithmetics on the 
poll table have become simpler as well.

So the patch has my ack:

  Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo
