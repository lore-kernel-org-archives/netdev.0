From: ebiederman@lnxi.com (Eric W. Biederman)
Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Sun, 18 Mar 2007 23:30:39 -0600
Message-ID: <m3aby94x6o.fsf@maxwell.lnxi.com>
References: <m3tzwi8a20.fsf@maxwell.lnxi.com>
	<20070318223653.GO11078@mellanox.co.il>
	<20070318224234.GP11078@mellanox.co.il>
	<20070318.171337.112622504.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org, kuznet@ms2.inr.ac.ru
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070318.171337.112622504.davem@davemloft.net> (David Miller's
	message of "Sun, 18 Mar 2007 17:13:37 -0700 (PDT)")
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

David Miller <davem@davemloft.net> writes:

> From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
> Date: Mon, 19 Mar 2007 00:42:34 +0200

>> > Hmm. Then the code moving dst->dev to point to the loopback
>> > device will have to be fixed too. I'll post a patch a bit later.
>> 
>> Does this look sane (untested)?
>> 
>> Signed-off-by: Michael S. Tsirkin <mst@dev.mellanox.co.il>
>
> You can't point it at NULL, we don't point it at loopback
> just for fun.
>
> There can be asynchronous paths elsewhere in the networking still
> referencing the neigh or dst and they will (correctly) feel free to
> derefence whatever device is hanging there.  So transitioning
> to NULL is invalid.
>
> You guys will need to come up with a better solution for this silly
> situation with network namespaces.  Loopback is always available to
> point dead routes and neighbour entries at, and this assumption is
> massively rooted in the networking.

Sure.  In the network namespace case I think the careful ordering of the
shutdown handles that case.   Even with per network namespace lo
unregistered it still existed until the network namespace actually
exited.  And it only happened on exit.  

So while there may be a tiny race there it hasn't been an issue yet
in practice.

I wasn't proposing that we fix it this way.  I was simply saying that
there was the possibility for the case to exist.  The existence of
a per network namespace loopback device is fairly fundamental to the
network namespace concept.  Heck I think Herbert has been looking at
it for vserver which almost totally socket isolation.

Eric
