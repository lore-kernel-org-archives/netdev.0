From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: split-lru performance mesurement part2
Date: Tue,  7 Oct 2008 23:26:54 +0900 (JST)
Message-ID: <20081007231851.3B88.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081003153810.5dd0a33e@bree.surriel.com> <20081004232549.CE53.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
To: Rik van Riel <riel@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:41931 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329AbYJGO06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 10:26:58 -0400
In-Reply-To: <20081004232549.CE53.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

> yup,
> I know many people want to other benchmark result too.
> I'll try to mesure other bench at next week.

I ran another benchmark today.
I choice dbench because dbench is one of most famous and real workload like i/o benchmark.


% dbench client.txt 4000

mainline:  Throughput 13.4231 MB/sec  4000 clients  4000 procs  max_latency=1421988.159 ms
mmotm(*):  Throughput  7.0354 MB/sec  4000 clients  4000 procs  max_latency=2369213.380 ms

(*) mmotm 2/Oct + Hugh's recently slub fix


Wow!
mmotm is slower than mainline largely (about half performance).

Therefore, I mesured it on "mainline + split-lru(only)" build.


mainline + split-lru(only): Throughput 14.4062 MB/sec  4000 clients  4000 procs  max_latency=1152231.896 ms


OK!
split-lru outperform mainline from viewpoint of both throughput and latency :)



However, I don't understand why this regression happend.
Do you have any suggestion?




