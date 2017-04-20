From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next v2 5/5] virtio-net: keep tx interrupts disabled
 unless kick
Date: Thu, 20 Apr 2017 10:03:26 -0400
Message-ID: <CAF=yD-KVwRkkGr=pGDmTTXtrrTuAuD7SmTPVtQuwu9aufoBeEQ@mail.gmail.com>
References: <20170418202108.61920-1-willemdebruijn.kernel@gmail.com>
 <20170418202108.61920-6-willemdebruijn.kernel@gmail.com> <72551dd3-ba91-812e-9065-d153bf8a7024@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:34647 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032098AbdDTOEI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 10:04:08 -0400
Received: by mail-qk0-f175.google.com with SMTP id y63so16690970qkd.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 07:04:08 -0700 (PDT)
In-Reply-To: <72551dd3-ba91-812e-9065-d153bf8a7024@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> -       if (!use_napi)
>> +       if (use_napi) {
>> +               if (kick)
>> +                       virtqueue_enable_cb_delayed(sq->vq);
>> +               else
>> +                       virtqueue_disable_cb(sq->vq);
>
>
> Since virtqueue_disable_cb() do nothing for event idx. I wonder whether or
> not just calling enable_cb_dealyed() is ok here.

Good point.

> Btw, it does not disable interrupt at all, I propose a patch in the past
> which can do more than this:
>
> https://patchwork.kernel.org/patch/6472601/

Interesting. Yes, let me evaluate that variant.

Thanks for reviewing,

  Willem
