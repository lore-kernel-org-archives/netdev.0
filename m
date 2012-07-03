From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 1/7] qlge: Fixed packet transmit errors due to potential driver errors.
Date: Wed, 4 Jul 2012 00:22:35 +0200
Message-ID: <20120703222235.GA14926@electric-eye.fr.zoreil.com>
References: <20120702.171854.1585295090835924398.davem@davemloft.net> <5E4F49720D0BAD499EE1F01232234BA877435B266A@AVEXMB1.qlogic.org> <20120702.183826.1521103644475572622.davem@davemloft.net> <20120702.184134.1131493483786674336.davem@davemloft.net> <5E4F49720D0BAD499EE1F01232234BA877435B2797@AVEXMB1.qlogic.org> <1341347235.2583.796.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47319 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119Ab2GCWeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 18:34:00 -0400
Content-Disposition: inline
In-Reply-To: <1341347235.2583.796.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
> On Tue, 2012-07-03 at 12:38 -0700, Jitendra Kalsaria wrote:
> 
> > I think my patch description might have been misleading. We are not
> > fixing a logical problem but rather a statistics reporting problem.
> > Our transmit function is not getting called when queue is full but
> > when we stop the queue it increment tx_error statistic and one of our
> > customers is running a test that deliberately floods the queue causing
> > it to periodically be stopped. The customer has not reported logical
> > problem with the test were driver perform very well but they merely
> > pointed out that we were incorrectly reporting the queue full
> > condition as a tx_error.
> > 
> > This patch was intended to remove the line that increments the
> > tx_error statistic when the queue is correctly stopped.
> 
> I believe everybody kindly ask you to fix the driver logic instead
> of trying to hide to your customers the problems.

:o/

Jitendra was speaking about qlge_ethtool_ops.self_test(). It will need
fixing as well.

> In fact, you could just BUG() at this point, and maybe David will accept
> such a patch.

Mildly. It would turn qlge_ethtool_ops.self_test() into a system killer.

[...]
> testing atomic_read(&tx_ring->tx_count) at the beginning of qlge_send()
> is too late. NETDEV_TX_BUSY is deprecated.

Yes.

Returning NETDEV_TX_BUSY when dma mapping fails in ql_map_send isn't nice
either.

-- 
Ueimor
