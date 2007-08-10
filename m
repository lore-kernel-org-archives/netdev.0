From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH 9/24] make atomic_read() behave consistently on ia64
Date: Fri, 10 Aug 2007 15:59:44 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A0224C8D7@scsmsx411.amr.corp.intel.com>
References: <20070809135107.GA15985@shell.boston.redhat.com><617E1C2C70743745A92448908E030B2A02213B3C@scsmsx411.amr.corp.intel.com><46BCC1AF.5050204@redhat.com><617E1C2C70743745A92448908E030B2A0224C777@scsmsx411.amr.corp.intel.com> <jewsw3oyl8.fsf@sykes.suse.de> <617E1C2C70743745A92448908E030B2A0224C88B@scsmsx411.amr.corp.intel.com> <46BCE9F8.4060009@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andreas Schwab" <schwab@suse.de>, <linux-kernel@vger.kernel.org>,
	<linux-arch@vger.kernel.org>, <torvalds@linux-foundation.org>,
	<netdev@vger.kernel.org>, <akpm@linux-foundation.org>,
	<ak@suse.de>, <heiko.carstens@de.ibm.com>, <davem@davemloft.net>,
	<schwidefsky@de.ibm.com>, <wensong@linux-vs.org>,
	<horms@verge.net.au>, <wjiang@resilience.com>,
	<cfriesen@nortel.com>, <zlynx@acm.org>, <rpjday@mindspring.com>,
	<jesper.juhl@gmail.com>
To: "Chris Snook" <csnook@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765006AbXHJXAB@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <46BCE9F8.4060009@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Possibly.  Either that or we've uncovered some latent bugs.  Maybe a 
> combination of the two.  Can you list those 19 changes so we can 
evaluate them?

Here are the functions in which they occur in the object file. You
may have to chase down some inlining to find the function that
actually uses atomic_*().

freeque
do_msgrcv
sk_free
sock_wfree
sock_rfree
sock_kmalloc
sock_kfree_s
sock_setsockopt
skb_release_data
__sk_stream_mem_reclaim
sk_tream_mem_schedule
sk_stream_rfree
sk_attach_filter
ip_frag_destroy * 2
ip_frag_queue * 2
ip_frag_reasm * 2

-Tony
