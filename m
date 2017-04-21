From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next v2 5/5] virtio-net: keep tx interrupts disabled
 unless kick
Date: Fri, 21 Apr 2017 19:13:57 -0400
Message-ID: <CAF=yD-LE1q=jYzEWS5aFb3OcNWDEL3agkSm495xC=ns0PJWFqw@mail.gmail.com>
References: <20170418202108.61920-1-willemdebruijn.kernel@gmail.com>
 <20170418202108.61920-6-willemdebruijn.kernel@gmail.com> <72551dd3-ba91-812e-9065-d153bf8a7024@redhat.com>
 <CAF=yD-KVwRkkGr=pGDmTTXtrrTuAuD7SmTPVtQuwu9aufoBeEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36024 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1042822AbdDUXOi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 19:14:38 -0400
Received: by mail-qk0-f195.google.com with SMTP id y63so4648853qkd.3
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 16:14:38 -0700 (PDT)
In-Reply-To: <CAF=yD-KVwRkkGr=pGDmTTXtrrTuAuD7SmTPVtQuwu9aufoBeEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 10:03 AM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
>>> -       if (!use_napi)
>>> +       if (use_napi) {
>>> +               if (kick)
>>> +                       virtqueue_enable_cb_delayed(sq->vq);
>>> +               else
>>> +                       virtqueue_disable_cb(sq->vq);
>>
>>
>> Since virtqueue_disable_cb() do nothing for event idx. I wonder whether or
>> not just calling enable_cb_dealyed() is ok here.
>
> Good point.
>
>> Btw, it does not disable interrupt at all, I propose a patch in the past
>> which can do more than this:
>>
>> https://patchwork.kernel.org/patch/6472601/
>
> Interesting. Yes, let me evaluate that variant.

In initial tests I don't see a significant change, but we can look
into this more closely as a follow-on patch.
