From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next RFC 2/4] virtio-net: transmit napi
Date: Mon, 6 Mar 2017 12:50:19 -0500
Message-ID: <CAF=yD-K8vEKdRK5YC-aRLgHf_5hXZObBQCP9N0FMertYMU-T3A@mail.gmail.com>
References: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
 <20170303143909.80001-3-willemdebruijn.kernel@gmail.com> <d60512a1-4210-b0c8-c672-bb6e3779936d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34920 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753944AbdCFR7k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 12:59:40 -0500
Received: by mail-wr0-f193.google.com with SMTP id u108so18752467wrb.2
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 09:59:39 -0800 (PST)
In-Reply-To: <d60512a1-4210-b0c8-c672-bb6e3779936d@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>   drivers/net/virtio_net.c | 73
>> ++++++++++++++++++++++++++++++++++++++++--------
>>   1 file changed, 61 insertions(+), 12 deletions(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 8c21e9a4adc7..9a9031640179 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -33,6 +33,8 @@
>>   static int napi_weight = NAPI_POLL_WEIGHT;
>>   module_param(napi_weight, int, 0444);
>>   +static int napi_tx_weight = NAPI_POLL_WEIGHT;
>> +
>
>
> Maybe we should use module_param for this? Or in the future, use
> tx-frames-irq for a per-device configuration.

This option should eventually just go away, and napi tx become the
standard mode.

In the short term, while we evaluate it on varied workloads, a
module_param sounds good to me. In general that is frowned
upon, as it leads to different configuration interfaces for each
device driver. But that should not be a concern in this limited
case.
