From: Matt Mackall <mpm@selenic.com>
Subject: Re: recent -git: BUG in free_thread_xstate
Date: Wed, 23 Jul 2008 18:53:55 -0500
Message-ID: <1216857235.15519.189.camel@calx>
References: <19f34abd0807231307y191c0ad7tfab4cda57ee88eb@mail.gmail.com>
	 <20080723203109.GH14380@linux-os.sc.intel.com>
	 <19f34abd0807231352j1ba1414am84ee9683df9b5657@mail.gmail.com>
	 <b647ffbd0807231422w546e59e9p8362ee798b169a25@mail.gmail.com>
	 <b647ffbd0807231435h73740808p76143d3d4457b597@mail.gmail.com>
	 <19f34abd0807231445h79fac5cbwecd0563b74bc18ad@mail.gmail.com>
	 <b647ffbd0807231501va30f6d4kee49d1daa30227fc@mail.gmail.com>
	 <19f34abd0807231505w1a25c2bak329a622f3a287e97@mail.gmail.com>
	 <19f34abd0807231545u5bc8b55fm768527a02268f111@mail.gmail.com>
	 <19f34abd0807231550h4ba88a9qa27b1c9e5afc80cb@mail.gmail.com>
	 <19f34abd0807231620q6d870bc0k74d176c9e5253ff3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Suresh Siddha <suresh.b.siddha@intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:52692 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756649AbYGXAHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 20:07:47 -0400
In-Reply-To: <19f34abd0807231620q6d870bc0k74d176c9e5253ff3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-07-24 at 01:20 +0200, Vegard Nossum wrote:
> >> +extern void warn_on_slowpath(const char *file, int line);

Mmm, fun.

> >>  [<c013496f>] warn_on_slowpath+0x4f/0x70
> >>  [<c0198041>] ? check_bytes_and_report+0x21/0xc0
> >>  [<c04a8544>] ? __kfree_skb+0x34/0x80
> >>  [<c0198041>] ? check_bytes_and_report+0x21/0xc0
> >>  [<c01983ef>] ? check_object+0xdf/0x1f0
> >>  [<c0198041>] ? check_bytes_and_report+0x21/0xc0
> >>  [<c04a8544>] ? __kfree_skb+0x34/0x80
> >>  [<c01983ef>] ? check_object+0xdf/0x1f0
> >>  [<c04bbafc>] ? find_skb+0x3c/0x80
> >>  [<c04a9f7e>] skb_copy_and_csum_dev+0xee/0x100
> >>  [<c03539d7>] rtl8139_start_xmit+0x57/0x130
> >>  [<c019a84b>] ? __kmalloc_track_caller+0x8b/0x120
> >>  [<c04bba6e>] netpoll_send_skb+0x14e/0x1a0
> >>  [<c04bbf54>] netpoll_send_udp+0x1e4/0x210

Trying to warn_on from inside a network driver from inside netpoll may
cause trouble.

-- 
Mathematics is the supreme nostalgia of our time.

