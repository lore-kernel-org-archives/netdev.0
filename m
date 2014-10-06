From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for
 direct ring access
Date: Mon, 6 Oct 2014 18:35:36 +0200
Message-ID: <20141006183536.329de8b0@redhat.com>
References: <20141006000629.32055.2295.stgit@nitbit.x32>
	<20141006002951.GA24376@breakpoint.cc>
	<5431EC82.7010305@gmail.com>
	<543265A5.8000606@redhat.com>
	<5432AEE0.9000600@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Daniel Borkmann <dborkman@redhat.com>,
	John Fastabend <john.fastabend@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Florian Westphal <fw@strlen.de>, gerlitz.or@gmail.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	john.ronciak@intel.com, amirv@mellanox.com, eric.dumazet@gmail.com,
	danny.zhou@intel.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40304 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751316AbaJFQgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 12:36:11 -0400
In-Reply-To: <5432AEE0.9000600@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 06 Oct 2014 08:01:52 -0700 John Fastabend <john.r.fastabend@intel.com> wrote:
 
> This requires a system call as far as I can tell. Which has unwanted
> overhead. I can micro-benchmark this if its helpful. But if we dredge
> up Jesper's slides here we are really counting cycles so even small
> numbers count if we want to hit line rate in a user space application
> with 40Gpbs hardware.

The micro-benchmarked syscall[2] cost is approx 42 ns [1] (when
disabling CONFIG_AUDITSYSCALL else its approx 88ns), which is
significant compared to the 10G wirespeed smallest packet size budget
of 67.2ns.

See:
 [1] http://netoptimizer.blogspot.dk/2014/05/the-calculations-10gbits-wirespeed.html
 [2] https://github.com/netoptimizer/network-testing/blob/master/src/syscall_overhead.c

[...] 
> We already added a qdisc bypass option I see this as taking this path
> further. I believe there is room for a continuum here. For basic cases
> use af_packet v1,v2 for mmap rings but using common descriptors use
> af_packet v3 and set QOS_BYASS. For absolute lowest overhead and
> specific applications that don't need QOS, eBPF use this interface.

Well, after the qdisc bulking changes, when bulking kicks in then the
qdisc path is faster than the qdisc bypass (measured with trafgen).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
