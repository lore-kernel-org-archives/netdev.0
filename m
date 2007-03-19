From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Mon, 19 Mar 2007 15:05:34 +0300
Message-ID: <20070319120534.GA28187@ms2.inr.ac.ru>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
	<20070318195355.GB11078@mellanox.co.il>
	<20070318201826.GB27004@ms2.inr.ac.ru>
	<20070319093632.GB8386@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	general@lists.openfabrics.org, David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070319093632.GB8386@mellanox.co.il>
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

> If a device driver sets neigh_destructor in neigh_params, this could
> get called after the device has been unregistered and the driver module
> removed.

It is the same problem: if dst->neighbour holds neighbour, it should
not hold device. parms->dev is not supposed to be used after
neigh_parms_release(). F.e. set parms->dev to NULL to catch bad references.


Do you search for a way to find real inifiniband device in
ipoib_neigh_destructor()? I guess you will not be able.
The problem is logical: if destructor needs device, neighbour entry
_somehow_ have to hold reference to the device (via neigh->dev, neigh->parms,
whatever). Hence, if we hold neighbour entry, unregister cannot be completed.
Therefore, destructor cannot refer to device. Q.E.D. :-)

Seems, releasing dst->neighbour is inevitable.

Alexey
