From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH RESEND net-next 07/15] smc: remote memory buffers (RMBs)
 (fwd)
Date: Tue, 9 Aug 2016 14:09:46 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1608091409080.2911@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, utz.bacher@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: Ursula Braun <ubraun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:32443
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932173AbcHIMVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 08:21:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there a guarantee that the contrinues can't fall off the end of the
loop?

julia

---------- Forwarded message ----------
Date: Tue, 9 Aug 2016 20:06:24 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH RESEND net-next 07/15] smc: remote memory buffers (RMBs)

CC: kbuild-all@01.org
In-Reply-To: <1470737580-43012-8-git-send-email-ubraun@linux.vnet.ibm.com>
TO: Ursula Braun <ubraun@linux.vnet.ibm.com>
CC: davem@davemloft.net
CC: netdev@vger.kernel.org, linux-s390@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com

Hi Ursula,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Ursula-Braun/net-smc-Shared-Memory-Communications-RDMA/20160809-182526
:::::: branch date: 2 hours ago
:::::: commit date: 2 hours ago

>> net/smc/smc_core.c:570:17-25: ERROR: reference preceded by free on line 549
   net/smc/smc_core.c:570:17-25: ERROR: reference preceded by free on line 560
   net/smc/smc_core.c:507:20-31: ERROR: reference preceded by free on line 486
   net/smc/smc_core.c:507:20-31: ERROR: reference preceded by free on line 497

git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout 2e8eda2734f14a860721121549f05e5ecd13d81d
vim +570 net/smc/smc_core.c

2e8eda27 Ursula Braun 2016-08-09  543  			break; /* give up with -ENOMEM */
2e8eda27 Ursula Braun 2016-08-09  544  		rmb_desc->cpu_addr = kzalloc(tmp_bufsize,
2e8eda27 Ursula Braun 2016-08-09  545  					     GFP_KERNEL | __GFP_NOWARN |
2e8eda27 Ursula Braun 2016-08-09  546  					     __GFP_NOMEMALLOC |
2e8eda27 Ursula Braun 2016-08-09  547  					     __GFP_NORETRY);
2e8eda27 Ursula Braun 2016-08-09  548  		if (!rmb_desc->cpu_addr) {
2e8eda27 Ursula Braun 2016-08-09 @549  			kfree(rmb_desc);
2e8eda27 Ursula Braun 2016-08-09  550  			/* if RMB allocation has failed,
2e8eda27 Ursula Braun 2016-08-09  551  			 * try a smaller one
2e8eda27 Ursula Braun 2016-08-09  552  			 */
2e8eda27 Ursula Braun 2016-08-09  553  			continue;
2e8eda27 Ursula Braun 2016-08-09  554  		}
2e8eda27 Ursula Braun 2016-08-09  555  		rc = smc_ib_buf_map(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
2e8eda27 Ursula Braun 2016-08-09  556  				    tmp_bufsize, rmb_desc,
2e8eda27 Ursula Braun 2016-08-09  557  				    DMA_FROM_DEVICE);
2e8eda27 Ursula Braun 2016-08-09  558  		if (rc) {
2e8eda27 Ursula Braun 2016-08-09  559  			kfree(rmb_desc->cpu_addr);
2e8eda27 Ursula Braun 2016-08-09  560  			kfree(rmb_desc);
2e8eda27 Ursula Braun 2016-08-09  561  			continue; /* if mapping failed, try smaller one */
2e8eda27 Ursula Braun 2016-08-09  562  		}
2e8eda27 Ursula Braun 2016-08-09  563  		rmb_desc->used = 1;
2e8eda27 Ursula Braun 2016-08-09  564  		write_lock_bh(&lgr->rmbs_lock);
2e8eda27 Ursula Braun 2016-08-09  565  		list_add(&rmb_desc->list,
2e8eda27 Ursula Braun 2016-08-09  566  			 &lgr->rmbs[tmp_bufsize_short]);
2e8eda27 Ursula Braun 2016-08-09  567  		write_unlock_bh(&lgr->rmbs_lock);
2e8eda27 Ursula Braun 2016-08-09  568  		break;
2e8eda27 Ursula Braun 2016-08-09  569  	}
2e8eda27 Ursula Braun 2016-08-09 @570  	if (rmb_desc && rmb_desc->cpu_addr) {
2e8eda27 Ursula Braun 2016-08-09  571  		conn->rmb_desc = rmb_desc;
2e8eda27 Ursula Braun 2016-08-09  572  		conn->rmbe_size = tmp_bufsize;
2e8eda27 Ursula Braun 2016-08-09  573  		conn->rmbe_size_short = tmp_bufsize_short;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
