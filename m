From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 0/5] XDP adjust head support for virtio
Date: Tue, 07 Feb 2017 10:05:36 -0500 (EST)
Message-ID: <20170207.100536.1452608171618649167.davem@davemloft.net>
References: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
        <20170207053455-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, kubakici@wp.pl, jasowang@redhat.com,
        ast@fb.com, john.r.fastabend@intel.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48572 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754354AbdBGPFn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 10:05:43 -0500
In-Reply-To: <20170207053455-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 7 Feb 2017 06:15:13 +0200

> On Thu, Feb 02, 2017 at 07:14:05PM -0800, John Fastabend wrote:
>> This series adds adjust head support for virtio. The following is my
>> test setup. I use qemu + virtio as follows,
>> 
>> ./x86_64-softmmu/qemu-system-x86_64 \
>>   -hda /var/lib/libvirt/images/Fedora-test0.img \
>>   -m 4096  -enable-kvm -smp 2 -netdev tap,id=hn0,queues=4,vhost=on \
>>   -device virtio-net-pci,netdev=hn0,mq=on,guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off,vectors=9
>> 
>> In order to use XDP with virtio until LRO is supported TSO must be
>> turned off in the host. The important fields in the above command line
>> are the following,
>> 
>>   guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off
>> 
>> Also note it is possible to conusme more queues than can be supported
>> because when XDP is enabled for retransmit XDP attempts to use a queue
>> per cpu. My standard queue count is 'queues=4'.
>> 
>> After loading the VM I run the relevant XDP test programs in,
>> 
>>   ./sammples/bpf
>> 
>> For this series I tested xdp1, xdp2, and xdp_tx_iptunnel. I usually test
>> with iperf (-d option to get bidirectional traffic), ping, and pktgen.
>> I also have a modified xdp1 that returns XDP_PASS on any packet to ensure
>> the normal traffic path to the stack continues to work with XDP loaded.
>> 
>> It would be great to automate this soon. At the moment I do it by hand
>> which is starting to get tedious.
>> 
>> v2: original series dropped trace points after merge.
> 
> So I'd say ok, let's go ahead and merge this for now.

Ok, done.  Thanks everyone.
