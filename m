From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net 1/7] qlge: Fixed packet transmit errors due to
 potential driver errors.
Date: Tue, 03 Jul 2012 22:27:15 +0200
Message-ID: <1341347235.2583.796.camel@edumazet-glaptop>
References: <20120702.171854.1585295090835924398.davem@davemloft.net>
	 <5E4F49720D0BAD499EE1F01232234BA877435B266A@AVEXMB1.qlogic.org>
	 <20120702.183826.1521103644475572622.davem@davemloft.net>
	 <20120702.184134.1131493483786674336.davem@davemloft.net>
	 <5E4F49720D0BAD499EE1F01232234BA877435B2797@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48295 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933388Ab2GCU1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 16:27:20 -0400
Received: by eeit10 with SMTP id t10so2645076eei.19
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2012 13:27:19 -0700 (PDT)
In-Reply-To: <5E4F49720D0BAD499EE1F01232234BA877435B2797@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-03 at 12:38 -0700, Jitendra Kalsaria wrote:

> I think my patch description might have been misleading. We are not
> fixing a logical problem but rather a statistics reporting problem.
> Our transmit function is not getting called when queue is full but
> when we stop the queue it increment tx_error statistic and one of our
> customers is running a test that deliberately floods the queue causing
> it to periodically be stopped. The customer has not reported logical
> problem with the test were driver perform very well but they merely
> pointed out that we were incorrectly reporting the queue full
> condition as a tx_error.
> 
> This patch was intended to remove the line that increments the
> tx_error statistic when the queue is correctly stopped.

I believe everybody kindly ask you to fix the driver logic instead
of trying to hide to your customers the problems.

In fact, you could just BUG() at this point, and maybe David will accept
such a patch.

testing atomic_read(&tx_ring->tx_count) at the beginning of qlge_send()
is too late. NETDEV_TX_BUSY is deprecated.

Well behaving drivers should perform the test at the end of their
ndo_start_xmit() and stop the queue so that next packet wont come at
all.
