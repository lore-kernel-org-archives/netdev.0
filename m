From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 7 Oct 2008 07:33:46 -0700
Message-ID: <20081007143346.GA6384@linux.vnet.ibm.com>
References: <20081006185026.GA10383@minyard.local> <48EA8197.6080502@cosmosbay.com> <20081006.144002.56418911.davem@davemloft.net> <48EA9A59.1090306@acm.org> <20081007083750.GB17079@2ka.mipt.ru> <48EB6F2D.100@linux-foundation.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754103AbYJGOki@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48EB6F2D.100@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 07, 2008 at 09:16:13AM -0500, Christoph Lameter wrote:
> Evgeniy Polyakov wrote:
> > On Mon, Oct 06, 2008 at 06:08:09PM -0500, Corey Minyard (minyard@acm.org) wrote:
> >> Would using SLAB_DESTROY_BY_RCU be ok, or would that be too expensive?
> > 
> > I tested skb destruction via RCU path, and got 2.5 times worse numbers
> > with small-packets-bulk-transfer workload.
> 
> Was this with regular RCU freeing? This will cool down the cacheline before
> frees. You need SLAB_DESTROY_BY_RCU to keep the objects cache hot.

Indeed!

But care is required -- SLAB_DESTROY_BY_RCU permits objects to be freed
and reallocated while a reader holds a reference.  The only guarantee is
that the -type- of the data structure will not change while a reader holds
a reference.  With something like UDP, this might well be sufficient.

Just be careful!  ;-)

							Thanx, Paul
