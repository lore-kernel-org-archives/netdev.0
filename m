From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [net-next PATCH v2 0/5] XDP adjust head support for virtio
Date: Thu, 2 Feb 2017 19:29:33 -0800
Message-ID: <5893F91D.2010909@fb.com>
References: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <john.r.fastabend@intel.com>, <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>, <kubakici@wp.pl>,
        <jasowang@redhat.com>, <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60712 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751944AbdBCD3r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 22:29:47 -0500
In-Reply-To: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/2/17 7:14 PM, John Fastabend wrote:
> This series adds adjust head support for virtio. The following is my
> test setup. I use qemu + virtio as follows,
>
> ./x86_64-softmmu/qemu-system-x86_64 \
>    -hda /var/lib/libvirt/images/Fedora-test0.img \
>    -m 4096  -enable-kvm -smp 2 -netdev tap,id=hn0,queues=4,vhost=on \
>    -device virtio-net-pci,netdev=hn0,mq=on,guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off,vectors=9
>
> In order to use XDP with virtio until LRO is supported TSO must be
> turned off in the host. The important fields in the above command line
> are the following,
>
>    guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off

thank you for sharing the command line!
Pretty hard to figure this out.
Too bad you dropped the patch that allows dynamic switch off of LRO.
Long term I don't see why guest shouldn't be allowed to turn that knob.

> Also note it is possible to conusme more queues than can be supported
> because when XDP is enabled for retransmit XDP attempts to use a queue
> per cpu. My standard queue count is 'queues=4'.
>
> After loading the VM I run the relevant XDP test programs in,
>
>    ./sammples/bpf
>
> For this series I tested xdp1, xdp2, and xdp_tx_iptunnel. I usually test
> with iperf (-d option to get bidirectional traffic), ping, and pktgen.
> I also have a modified xdp1 that returns XDP_PASS on any packet to ensure
> the normal traffic path to the stack continues to work with XDP loaded.

same here.
xdp testing requires two physical machines with specific nics,
so hard to automate.
At least the virtio+xdp gives us ability to test the programs
automatically. So virtio+xdp will get the most test coverage and
all hw nics will be using it as a yardstick. Very important to
make it easy to use.

For bpf and generic xdp bits:
Acked-by: Alexei Starovoitov <ast@kernel.org>
