From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 0/5] XDP adjust head support for virtio
Date: Sun, 05 Feb 2017 17:36:34 -0500 (EST)
Message-ID: <20170205.173634.457797928882804290.davem@davemloft.net>
References: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kubakici@wp.pl, jasowang@redhat.com, ast@fb.com, mst@redhat.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44332 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751319AbdBEWgg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 17:36:36 -0500
In-Reply-To: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Thu, 02 Feb 2017 19:14:05 -0800

> This series adds adjust head support for virtio. The following is my
> test setup. I use qemu + virtio as follows,
> 
> ./x86_64-softmmu/qemu-system-x86_64 \
>   -hda /var/lib/libvirt/images/Fedora-test0.img \
>   -m 4096  -enable-kvm -smp 2 -netdev tap,id=hn0,queues=4,vhost=on \
>   -device virtio-net-pci,netdev=hn0,mq=on,guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off,vectors=9
> 
> In order to use XDP with virtio until LRO is supported TSO must be
> turned off in the host. The important fields in the above command line
> are the following,
> 
>   guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off
> 
> Also note it is possible to conusme more queues than can be supported
> because when XDP is enabled for retransmit XDP attempts to use a queue
> per cpu. My standard queue count is 'queues=4'.
> 
> After loading the VM I run the relevant XDP test programs in,
> 
>   ./sammples/bpf
> 
> For this series I tested xdp1, xdp2, and xdp_tx_iptunnel. I usually test
> with iperf (-d option to get bidirectional traffic), ping, and pktgen.
> I also have a modified xdp1 that returns XDP_PASS on any packet to ensure
> the normal traffic path to the stack continues to work with XDP loaded.
> 
> It would be great to automate this soon. At the moment I do it by hand
> which is starting to get tedious.
> 
> v2: original series dropped trace points after merge.

Michael, I just want to apply this right now.

I don't think haggling over whether to allocate the adjust_head area
unconditionally or not is a blocker for this series going in.  That
can be addressed trivially in a follow-on patch.

We want these new reset paths tested as much as possible and each day
we delay this series is detrimental towards that goal.

Thanks.
