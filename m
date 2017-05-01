From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] virtio_net: make use of extended ack
 message reporting
Date: Mon, 01 May 2017 10:34:47 -0400 (EDT)
Message-ID: <20170501.103447.1197722529092618421.davem@davemloft.net>
References: <20170501044648.13022-1-jakub.kicinski@netronome.com>
        <20170501044648.13022-5-jakub.kicinski@netronome.com>
        <5907130F.7070807@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        johannes@sipsolutions.net, dsa@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com, brouer@redhat.com, jhs@mojatatu.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33024 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035157AbdEAOew (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 10:34:52 -0400
In-Reply-To: <5907130F.7070807@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 01 May 2017 12:50:55 +0200

> On 05/01/2017 06:46 AM, Jakub Kicinski wrote:
>> Try to carry error messages to the user via the netlink extended
>> ack message attribute.
>>
>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> 
> [...]
>> @@ -1890,16 +1891,17 @@ static int virtnet_xdp_set(struct net_device
>> *dev, struct bpf_prog *prog)
>>   	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6) ||
>>   	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ECN) ||
>>   	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_UFO)) {
>> -		netdev_warn(dev, "can't set XDP while host is implementing LRO, disable
>> -		LRO first\n");
>> + NL_SET_ERR_MSG(extack, "can't set XDP while host is implementing
>> LRO, disable LRO first");
> 
> Should this be NL_MOD_TRY_SET_ERR_MSG() as well like in nfp case
> (otherwise the 'if (_extack)' check might be missing from the
> macro)?

I don't see a path in the doit callchain for setlink/newlink where the
extack pointer can be null.

I'm going to apply this series and we should either:

1) Guarantee the extack object is always available.

or

2) Make all macros including NL_SET_ERR_MSG() check the
   pointer.

Thanks.
