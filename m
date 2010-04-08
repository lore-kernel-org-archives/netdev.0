From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: hackbench regression due to commit 9dfc6e68bfe6e
Date: Thu, 08 Apr 2010 07:39:13 +0200
Message-ID: <1270705153.8141.58.camel@edumazet-laptop>
References: <1269506457.4513.141.camel@alexs-hp.sh.intel.com>
	 <alpine.DEB.2.00.1003250942080.2670@router.home>
	 <1269570902.9614.92.camel@alexs-hp.sh.intel.com>
	 <1270114166.2078.107.camel@ymzhang.sh.intel.com>
	 <alpine.DEB.2.00.1004011050340.16531@router.home>
	 <1270195589.2078.116.camel@ymzhang.sh.intel.com>
	 <alpine.DEB.2.00.1004050853300.23149@router.home>
	 <i2z84144f021004051030k7ff5190cyc083aa12c552dfac@mail.gmail.com>
	 <4BBA8DF9.8010409@kernel.org>
	 <1270542497.2078.123.camel@ymzhang.sh.intel.com>
	 <alpine.DEB.2.00.1004061033330.18750@router.home>
	 <alpine.DEB.2.00.1004061552500.19151@router.home>
	 <1270591841.2091.170.camel@edumazet-laptop>
	 <1270607668.2078.259.camel@ymzhang.sh.intel.com>
	 <alpine.DEB.2.00.1004071130260.13261@router.home>
	 <4BBCB7B7.4040901@cs.helsinki.fi> <4BBCB868.2000705@cs.helsinki.fi>
	 <alpine.DEB.2.00.1004071319320.16159@router.home>
	 <1270665484.8141.47.camel@edumazet-laptop>
	 <1270688747.2078.383.camel@ymzhang.sh.intel.com>
	 <1270702774.8141.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
	alex.shi@intel.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ma, Ling" <ling.ma@intel.com>,
	"Chen, Tim C" <tim.c.chen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:45449 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022Ab0DHFjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 01:39:20 -0400
In-Reply-To: <1270702774.8141.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I suspect NUMA is completely out of order on current kernel, or my
Nehalem machine NUMA support is a joke

# numactl --hardware
available: 2 nodes (0-1)
node 0 size: 3071 MB
node 0 free: 2637 MB
node 1 size: 3062 MB
node 1 free: 2909 MB


# cat try.sh
hackbench 50 process 5000
numactl --cpubind=0 --membind=0 hackbench 25 process 5000 >RES0 &
numactl --cpubind=1 --membind=1 hackbench 25 process 5000 >RES1 &
wait
echo node0 results
cat RES0
echo node1 results
cat RES1

numactl --cpubind=0 --membind=1 hackbench 25 process 5000 >RES0_1 &
numactl --cpubind=1 --membind=0 hackbench 25 process 5000 >RES1_0 &
wait
echo node0 on mem1 results
cat RES0_1
echo node1 on mem0 results
cat RES1_0

# ./try.sh
Running with 50*40 (== 2000) tasks.
Time: 16.865
node0 results
Running with 25*40 (== 1000) tasks.
Time: 16.767
node1 results
Running with 25*40 (== 1000) tasks.
Time: 16.564
node0 on mem1 results
Running with 25*40 (== 1000) tasks.
Time: 16.814
node1 on mem0 results
Running with 25*40 (== 1000) tasks.
Time: 16.896


