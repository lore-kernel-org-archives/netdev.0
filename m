From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net] virtio_net: reject XDP programs using header adjustment
Date: Tue, 20 Dec 2016 12:30:39 +0000
Message-ID: <CAJpBn1wKkJ83GLznzQ+DCs7JZb-FkQ-zYu3d6i4p1RmfKy0mig@mail.gmail.com>
References: <20161219150500.2600-1-jakub.kicinski@netronome.com> <58581E01.7070902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, kafai@fb.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        alexei.starovoitov@gmail.com, mst@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:35233 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757447AbcLTMal (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 07:30:41 -0500
Received: by mail-qt0-f175.google.com with SMTP id c47so174990694qtc.2
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 04:30:40 -0800 (PST)
In-Reply-To: <58581E01.7070902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2016 at 5:50 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 16-12-19 07:05 AM, Jakub Kicinski wrote:
>> commit 17bedab27231 ("bpf: xdp: Allow head adjustment in XDP prog")
>> added a new XDP helper to prepend and remove data from a frame.
>> Make virtio_net reject programs making use of this helper until
>> proper support is added.
>>
>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>> ---
>>  drivers/net/virtio_net.c | 5 +++++
>>  1 file changed, 5 insertions(+)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 08327e005ccc..db761f37783e 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -1677,6 +1677,11 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>>       u16 xdp_qp = 0, curr_qp;
>>       int i, err;
>>
>> +     if (prog && prog->xdp_adjust_head) {
>> +             netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
>> +             return -EOPNOTSUPP;
>> +     }
>> +
>>       if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
>>           virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6)) {
>>               netdev_warn(dev, "can't set XDP while host is implementing LRO, disable LRO first\n");
>>
>
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
>
> Thanks patch looks good. Alternatively we could push a "bug fix" to
> support the adjust header feature depending on how DaveM and MST feel
> about that. I don't have a strong opinion but I have the patch on my
> queue it just needs some more testing.

Cool!  I thought to ask you what your plans are but then this patch is so
trivial I decided to just post it :) I'm perfectly happy with dropping it
for now and reposting after ~rc5 if needed.
