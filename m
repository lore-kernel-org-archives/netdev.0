From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Sun, 18 Mar 2007 22:24:44 +0200
Message-ID: <20070318202444.GC11078@mellanox.co.il>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
	<20070318194638.GA11078@mellanox.co.il>
	<20070318195558.GA27004@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	general@lists.openfabrics.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070318195558.GA27004@ms2.inr.ac.ru>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

> Quoting Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>:
> Subject: Re: dst_ifdown breaks infiniband?
> 
> Hello!
> 
> > Hmm. Something I don't understand: does the code
> > in question not run on *each* device unregister?
> 
> It does.
> 
> 
> > Why do I only see this under stress?
> 
> You should have some referenced destination entries to trigger bad path.
> This should happen not only under stress.
> 
> F.e. just try to ssh to something via this device. And unregister it.
> Seems, the crash is inevitable. If you do not see crash, I will be puzzled.


I did this.
What happens is:

	neigh_setup is called
	dst_ifdown changes the neigh->dev to loopback device

But the funny thing is that this neighbour can thinkably hang
around indefinitely now, and if it does destructor won't be called
and there won't be a crash.

To trigger a crash, I did simply
	ifconfig lo down; ifconfig lo 127.0.0.1

and sure enough it crashes in drivers/infiniband/ulp/ipoib/ipoib_main.c.

-- 
MST
