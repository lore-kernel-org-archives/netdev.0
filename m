From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH net-2.6.24] Fix refcounting problem with
 netif_rx_reschedule()
Date: Tue, 18 Sep 2007 13:15:05 -0700 (PDT)
Message-ID: <20070918.131505.91210517.davem@davemloft.net>
References: <20070918111803.1769.60619.sendpatchset@localhost.localdomain>
	<adawsunkg8i.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adawsunkg8i.fsf@cisco.com>
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

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 18 Sep 2007 10:58:37 -0700

> netif_rx_complete() takes a netdev parameter and does dev_put() on
> that netdev, so netif_rx_reschedule() needs to also take a netdev
> parameter and do dev_hold() on it to avoid reference counts from
> getting becoming negative because of unbalanced dev_put()s.
> 
> This should fix the problem reported by Krishna Kumar
> <krkumar2@in.ibm.com> with IPoIB waiting forever for netdev refcounts
> to become 0 during module unload.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>

Applied to net-2.6.24, thanks Roland.

> BTW, it looks like drivers/net/ibm_emac/ibm_emac_mal.c would not have 
> built in the current net-2.6.24 tree, since its call to
> netif_rx_reschedule() was left with the netdev parameter.  So that
> file does not need to be touched in this patch.

Yes, I know, this is the one NAPI driver that hasn't been converted.

It's a complicated conversion because of how the driver and the data
structures have been arranged (in short, a mess) which makes it
insanely difficult to get from a queue instance back up to a network
device or similar.

Further complicating things is that you need to setup a ppc32
cross-build environment to even build test a conversion, and I'm not
comfortable doing the surgery until I can test build the thing.

And this may be hard to believe, but other things have been more
pressing than setting up a ppc32 cross-build environment :-)

This is a hint of anyone looking for something to do that it'd
be much appreciated for someone to tackle the ibm_emac conversion.

Thanks.
