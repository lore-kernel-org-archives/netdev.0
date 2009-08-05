From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: Boot lockups triggered by 'net: restore the original spinlock
	to protect unicast list'
Date: Wed, 5 Aug 2009 15:40:05 +0200
Message-ID: <20090805134004.GG3897@psychotron.englab.brq.redhat.com>
References: <20090805133659.GA3740@rakim.wolfsonmicro.main>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Meelis Roos <mroos@linux.ee>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45216 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934397AbZHENkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 09:40:16 -0400
Content-Disposition: inline
In-Reply-To: <20090805133659.GA3740@rakim.wolfsonmicro.main>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 05, 2009 at 03:36:59PM CEST, broonie@opensource.wolfsonmicro.com wrote:
>I'm experiencing lockups at boot in -next with the loopback interface on
>my SMDK6410.  These appear to be triggered by commit
>a6ac65db2329e7685299666f5f7b6093c7b0f3a0 (net: restore the original
>spinlock to protect unicast list) - the code change is suspicious and
>reverting the change allows my system to boot.  I've not yet tried to
>understand the failure, I'm just reporting it.

Try this patch
http://marc.info/?l=linux-kernel&m=124945666109347&w=2

That should fix this.

>
>The console trace I get on failure is:
>
>[    1.830000] BUG: spinlock bad magic on CPU#0, swapper/1                      
>[    1.830000]  lock: c7852508, .magic: 00000000, .owner: <none>/-1, .owner_cpu0
>[    1.840000] [<c002fdc8>] (unwind_backtrace+0x0/0xe0) from [<c01679fc>] (_raw)
>[    1.850000] [<c01679fc>] (_raw_spin_lock+0x20/0x98) from [<c020ac40>] (dev_u)
>[    1.860000] [<c020ac40>] (dev_unicast_init+0x18/0x3c) from [<c020ebf8>] (all)
>[    1.860000] [<c020ebf8>] (alloc_netdev_mq+0xbc/0x13c) from [<c001b210>] (loo)
>[    1.870000] [<c001b210>] (loopback_net_init+0x1c/0x70) from [<c02096e4>] (re)
>[    1.880000] [<c02096e4>] (register_pernet_operations+0x20/0x2c) from [<c0209)
>[    1.890000] [<c0209778>] (register_pernet_device+0x20/0x54) from [<c001cbbc>)
>[    1.900000] [<c001cbbc>] (net_dev_init+0xd0/0x15c) from [<c0029274>] (do_one)
>[    1.910000] [<c0029274>] (do_one_initcall+0x4c/0x174) from [<c0008640>] (do_)
>[    1.920000] [<c0008640>] (do_initcalls+0x1c/0x38) from [<c0008a04>] (kernel_)
>[    1.930000] [<c0008a04>] (kernel_init+0x3c/0x8c) from [<c002ac98>] (kernel_t)
>[    9.930000] BUG: spinlock lockup on CPU#0, swapper/1, c7852508               
>[    9.930000] [<c002fdc8>] (unwind_backtrace+0x0/0xe0) from [<c01679c8>] (__sp)
>[    9.940000] [<c01679c8>] (__spin_lock_debug+0x88/0x9c) from [<c0167a54>] (_r)
>[    9.940000] [<c0167a54>] (_raw_spin_lock+0x78/0x98) from [<c020ac40>] (dev_u)
>[    9.950000] [<c020ac40>] (dev_unicast_init+0x18/0x3c) from [<c020ebf8>] (all)
>[    9.960000] [<c020ebf8>] (alloc_netdev_mq+0xbc/0x13c) from [<c001b210>] (loo)
>[    9.970000] [<c001b210>] (loopback_net_init+0x1c/0x70) from [<c02096e4>] (re)
>[    9.980000] [<c02096e4>] (register_pernet_operations+0x20/0x2c) from [<c0209)
>[    9.990000] [<c0209778>] (register_pernet_device+0x20/0x54) from [<c001cbbc>)
>[   10.000000] [<c001cbbc>] (net_dev_init+0xd0/0x15c) from [<c0029274>] (do_one)
>[   10.010000] [<c0029274>] (do_one_initcall+0x4c/0x174) from [<c0008640>] (do_)
>[   10.020000] [<c0008640>] (do_initcalls+0x1c/0x38) from [<c0008a04>] (kernel_)
>[   10.030000] [<c0008a04>] (kernel_init+0x3c/0x8c) from [<c002ac98>] (kernel_t)
