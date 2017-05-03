From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/4] samples/bpf: adjust rlimit RLIMIT_MEMLOCK
 for traceex2, tracex3 and tracex4
Date: Wed, 03 May 2017 09:31:50 -0400 (EDT)
Message-ID: <20170503.093150.577196301654107151.davem@davemloft.net>
References: <149372826543.22268.3617359219409721129.stgit@firesoul>
        <149372831091.22268.12527267276516941574.stgit@firesoul>
        <20170503005314.7oovr764r3e4elzd@ast-mbp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, kafai@fb.com, netdev@vger.kernel.org,
        eric@regit.org, borkmann@iogearbox.net
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36760 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751176AbdECNbw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 09:31:52 -0400
In-Reply-To: <20170503005314.7oovr764r3e4elzd@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 2 May 2017 17:53:16 -0700

> On Tue, May 02, 2017 at 02:31:50PM +0200, Jesper Dangaard Brouer wrote:
>> Needed to adjust max locked memory RLIMIT_MEMLOCK for testing these bpf samples
>> as these are using more and larger maps than can fit in distro default 64Kbytes limit.
>> 
>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ...
>> +	struct rlimit r = {1024*1024, RLIM_INFINITY};
> ...
>> +	struct rlimit r = {1024*1024, RLIM_INFINITY};
> 
> why magic numbers?
> All other samples do
> struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};

Let's not do that.

People run these tests often as root, so the safer we make running
these test the better.

A weird magic limit is better than none at all.
