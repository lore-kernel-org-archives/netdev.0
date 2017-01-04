From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH] virtio_net: XDP support for adjust_head
Date: Wed, 4 Jan 2017 11:21:18 +0800
Message-ID: <ec43c1a6-daf1-392a-8776-3f6597bea88e@redhat.com>
References: <20170102194413.9089.39078.stgit@john-Precision-Tower-5810>
 <73715f7a-eeeb-679f-a7b8-7b1fefe1757e@redhat.com>
 <586BD734.7020105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53614 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756640AbdADD3L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 22:29:11 -0500
In-Reply-To: <586BD734.7020105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月04日 00:54, John Fastabend wrote:
>>> +    /* Changing the headroom in buffers is a disruptive operation because
>>> +     * existing buffers must be flushed and reallocated. This will happen
>>> +     * when a xdp program is initially added or xdp is disabled by removing
>>> +     * the xdp program.
>>> +     */
>> We probably need reset the device here, but maybe Michale has more ideas. And if
>> we do this, another interesting thing to do is to disable EWMA and always use a
>> single page for each packet, this could almost eliminate linearizing.
> Well with normal MTU 1500 size we should not hit the linearizing case right?

My reply may be not clear, for 1500 I mean for small buffer only.

Thanks

>   The
> question is should we cap the MTU at GOOD_PACKET_LEN vs the current cap of
> (PAGE_SIZE - overhead).
>
