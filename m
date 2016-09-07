From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: Re: [net:master 29/33] drivers/net/ethernet/cadence/macb.c:1385:2-8:
 preceding lock on line 1372
Date: Wed, 07 Sep 2016 11:22:58 +0800
Message-ID: <277168dea8644a82ec6aa12b9f656a47@newmail.lip6.fr>
References: <201609071153.iChpWx76%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Cc: kbuild@01.org, netdev@vger.kernel.org
To: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isis.lip6.fr ([132.227.60.2]:61776 "EHLO isis.lip6.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755994AbcIGDdx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 23:33:53 -0400
In-Reply-To: <201609071153.iChpWx76%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lock acquired on line 1372 is still held when leaving the function 
at line 1385.  Is this intentional?

thanks,
julia



Le 07.09.2016 11:11, kbuild test robot a écrit :
> CC: kbuild-all@01.org
> CC: netdev@vger.kernel.org
> TO: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 
> master
> head:   751eb6b6042a596b0080967c1a529a9fe98dac1d
> commit: 007e4ba3ee137f4700f39aa6dbaf01a71047c5f6 [29/33] net: macb:
> initialize checksum when using checksum offloading
> :::::: branch date: 6 hours ago
> :::::: commit date: 6 hours ago
> 
>>> drivers/net/ethernet/cadence/macb.c:1385:2-8: preceding lock on line 
>>> 1372
> 
> git remote add net 
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
> git remote update net
> git checkout 007e4ba3ee137f4700f39aa6dbaf01a71047c5f6
> vim +1385 drivers/net/ethernet/cadence/macb.c
> 
> a4c35ed3f drivers/net/ethernet/cadence/macb.c Cyrille Pitchen
> 2014-07-24  1366  	nr_frags = skb_shinfo(skb)->nr_frags;
> a4c35ed3f drivers/net/ethernet/cadence/macb.c Cyrille Pitchen
> 2014-07-24  1367  	for (f = 0; f < nr_frags; f++) {
> a4c35ed3f drivers/net/ethernet/cadence/macb.c Cyrille Pitchen
> 2014-07-24  1368  		frag_size =
> skb_frag_size(&skb_shinfo(skb)->frags[f]);
> 94b295edc drivers/net/ethernet/cadence/macb.c Andy Shevchenko
> 2015-07-24  1369  		count += DIV_ROUND_UP(frag_size,
> bp->max_tx_length);
> a4c35ed3f drivers/net/ethernet/cadence/macb.c Cyrille Pitchen
> 2014-07-24  1370  	}
> a4c35ed3f drivers/net/ethernet/cadence/macb.c Cyrille Pitchen
> 2014-07-24  1371
> 4871953c0 drivers/net/macb.c                  Dongdong Deng
> 2009-08-23 @1372  	spin_lock_irqsave(&bp->lock, flags);
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen
> 2006-11-09  1373
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen
> 2006-11-09  1374  	/* This is a hard error, log it. */
> 02c958dd3 drivers/net/ethernet/cadence/macb.c Cyrille Pitchen
> 2014-12-12  1375  	if (CIRC_SPACE(queue->tx_head, queue->tx_tail,
> TX_RING_SIZE) < count) {
> 02c958dd3 drivers/net/ethernet/cadence/macb.c Cyrille Pitchen
> 2014-12-12  1376  		netif_stop_subqueue(dev, queue_index);
> 4871953c0 drivers/net/macb.c                  Dongdong Deng
> 2009-08-23  1377  		spin_unlock_irqrestore(&bp->lock, flags);
> c220f8cd0 drivers/net/ethernet/cadence/macb.c Jamie Iles
> 2011-03-08  1378  		netdev_dbg(bp->dev, "tx_head = %u, tx_tail =
> %u\n",
> 02c958dd3 drivers/net/ethernet/cadence/macb.c Cyrille Pitchen
> 2014-12-12  1379  			   queue->tx_head, queue->tx_tail);
> 5b5481402 drivers/net/macb.c                  Patrick McHardy
> 2009-06-12  1380  		return NETDEV_TX_BUSY;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen
> 2006-11-09  1381  	}
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen
> 2006-11-09  1382
> 007e4ba3e drivers/net/ethernet/cadence/macb.c Helmut Buchsbaum
> 2016-09-04  1383  	if (macb_clear_csum(skb)) {
> 007e4ba3e drivers/net/ethernet/cadence/macb.c Helmut Buchsbaum
> 2016-09-04  1384  		dev_kfree_skb_any(skb);
> 007e4ba3e drivers/net/ethernet/cadence/macb.c Helmut Buchsbaum
> 2016-09-04 @1385  		return NETDEV_TX_OK;
> 007e4ba3e drivers/net/ethernet/cadence/macb.c Helmut Buchsbaum
> 2016-09-04  1386  	}
> 007e4ba3e drivers/net/ethernet/cadence/macb.c Helmut Buchsbaum
> 2016-09-04  1387
> a4c35ed3f drivers/net/ethernet/cadence/macb.c Cyrille Pitchen
> 2014-07-24  1388  	/* Map socket buffer for DMA transfer */
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology 
> Center
> https://lists.01.org/pipermail/kbuild-all                   Intel 
> Corporation
