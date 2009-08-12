From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix spinlock use in alloc_netdev_mq()
Date: Wed, 12 Aug 2009 16:44:12 -0700 (PDT)
Message-ID: <20090812.164412.266822784.davem@davemloft.net>
References: <20090805084746.GA3897@psychotron.englab.brq.redhat.com>
	<20090805101327.2c49cc62.akpm@linux-foundation.org>
	<20090806083102.GA3737@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, mingo@elte.hu, a.p.zijlstra@chello.nl,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com
To: jpirko@redhat.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751762AbZHLXoF@vger.kernel.org>
In-Reply-To: <20090806083102.GA3737@psychotron.englab.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 6 Aug 2009 10:31:02 +0200

> Hmm, I see your point here. Eric previously posted patch which moved spin lock
> init into alloc_netdev_mq(). But he was worried about having it here and
> netdev_set_addr_lockdep_class() in register_netdevice() (because before
> dev_unicast_init() dev->type is not set). So how about the following patch?

Well, because of those potential late dev->type settings we
can't do things this way.  And I believe those in fact do happen.

So I'm tossing this patch, I wouldn't have applied it to net-2.6
anyways, as it's net-next-2.6 material :-)
