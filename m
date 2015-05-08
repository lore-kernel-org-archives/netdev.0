From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] net: deinline netif_tx_stop_queue() and
 netif_tx_stop_all_queues()
Date: Fri, 8 May 2015 10:30:03 -0700
Message-ID: <20150508172959.GA944@Alexeis-MBP.westell.com>
References: <1430998870-1453-1-git-send-email-dvlasenk@redhat.com>
 <554B9D82.80101@gmail.com>
 <554C85B2.1010605@redhat.com>
 <554CDB4D.5050108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <554CDB4D.5050108@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 08, 2015 at 08:50:37AM -0700, Alexander Duyck wrote:
> 
> >>>         f0 80 8f e0 01 00 00 01 lock orb $0x1,0x1e0(%rdi)
> >>This is your set bit operation.  If you were to drop the whole WARN_ON
> >>then this is the only thing you would be inlining.
> >It's up to networking people to decide. I would happily send a patch which drops
> >WARN_ON if they say that's ok with them. Davem?
> 
> This was added under commit 18543a643fae6 ("net: Detect and ignore
> netif_stop_queue() calls before register_netdev()").  I think the time for
> allowing drivers to ignore the WARN_ON has passed and at this point they
> should be strongly encouraged to fix the issue via a NULL pointer
> dereference if they still haven't gotten the issue resolved so we can track
> them down and fix them.  I'd say add a comment here in case someone triggers
> this and does some debugging, but the WARN_ON at this point has proven it is
> too expensive.

+1
5 years for this WARN_ON was enough. Time to remove it.
