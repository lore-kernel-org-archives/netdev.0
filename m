From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] virtio_net: reject XDP programs using header
 adjustment
Date: Fri, 23 Dec 2016 10:44:29 -0800
Message-ID: <585D708D.6000204@gmail.com>
References: <20161219150500.2600-1-jakub.kicinski@netronome.com>
 <58581E01.7070902@gmail.com>
 <CAJpBn1wKkJ83GLznzQ+DCs7JZb-FkQ-zYu3d6i4p1RmfKy0mig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kafai@fb.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        alexei.starovoitov@gmail.com, mst@redhat.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35001 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932291AbcLWSoo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 13:44:44 -0500
Received: by mail-pg0-f65.google.com with SMTP id i5so1285540pgh.2
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2016 10:44:44 -0800 (PST)
In-Reply-To: <CAJpBn1wKkJ83GLznzQ+DCs7JZb-FkQ-zYu3d6i4p1RmfKy0mig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-20 04:30 AM, Jakub Kicinski wrote:
> On Mon, Dec 19, 2016 at 5:50 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> On 16-12-19 07:05 AM, Jakub Kicinski wrote:
>>> commit 17bedab27231 ("bpf: xdp: Allow head adjustment in XDP prog")
>>> added a new XDP helper to prepend and remove data from a frame.
>>> Make virtio_net reject programs making use of this helper until
>>> proper support is added.
>>>
>>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>>> ---
>>>  drivers/net/virtio_net.c | 5 +++++
>>>  1 file changed, 5 insertions(+)
>>>
>>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>>> index 08327e005ccc..db761f37783e 100644
>>> --- a/drivers/net/virtio_net.c
>>> +++ b/drivers/net/virtio_net.c
>>> @@ -1677,6 +1677,11 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>>>       u16 xdp_qp = 0, curr_qp;
>>>       int i, err;
>>>
>>> +     if (prog && prog->xdp_adjust_head) {
>>> +             netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
>>> +             return -EOPNOTSUPP;
>>> +     }
>>> +
>>>       if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
>>>           virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6)) {
>>>               netdev_warn(dev, "can't set XDP while host is implementing LRO, disable LRO first\n");
>>>
>>
>> Acked-by: John Fastabend <john.r.fastabend@intel.com>
>>
>> Thanks patch looks good. Alternatively we could push a "bug fix" to
>> support the adjust header feature depending on how DaveM and MST feel
>> about that. I don't have a strong opinion but I have the patch on my
>> queue it just needs some more testing.
> 
> Cool!  I thought to ask you what your plans are but then this patch is so
> trivial I decided to just post it :) I'm perfectly happy with dropping it
> for now and reposting after ~rc5 if needed.
> 

Hi Jakub,

I just posted a RFC take a look if you get a chance. Notice though Jason
fixed up my linearize path a bunch so it will need to be pushed on top
of that series.

Thanks,
John
