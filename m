From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Mon, 19 Mar 2007 15:59:19 +0300
Message-ID: <20070319125919.GA4239@ms2.inr.ac.ru>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
	<20070318195355.GB11078@mellanox.co.il>
	<20070318201826.GB27004@ms2.inr.ac.ru>
	<20070319093632.GB8386@mellanox.co.il>
	<20070319120534.GA28187@ms2.inr.ac.ru>
	<20070319121248.GD18497@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	general@lists.openfabrics.org, David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070319121248.GD18497@mellanox.co.il>
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

Hello!

> infiniband sets parm->neigh_destructor, and I search for a way to prevent
> this destructor from being called after the module has been unloaded.
> Ideas?

It must be called in any case to update/release internal ipoib structures.

The idea is to move call of parm->neigh_destructor from neighbour destructor
to the moment when it is unhashed, right after n->dead is set.

infiniband is the only user (atm clip uses it too, but that use is obviously
dummy), so that nobody will be harmed.

But ipoib will have to check for validity of skb->dst->neighbour before
attempt to reinitialize private data on dead (n->dead != 0) neighbour.

Alexey
