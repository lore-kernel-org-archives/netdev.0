From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC 2/2] virtio_net: enable probing for NEEDS_RESET support
Date: Tue, 29 Aug 2017 16:27:41 -0400
Message-ID: <CAF=yD-L95x1EPKFeiPiZ2hbTzwYmDaG9O54+0tUW_4opuRKDMw@mail.gmail.com>
References: <20170829200759.13975-1-willemdebruijn.kernel@gmail.com>
 <20170829200759.13975-3-willemdebruijn.kernel@gmail.com> <20170829231606-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:38132 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751419AbdH2U2W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 16:28:22 -0400
Received: by mail-oi0-f66.google.com with SMTP id r203so3960321oih.5
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 13:28:22 -0700 (PDT)
In-Reply-To: <20170829231606-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 4:16 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Tue, Aug 29, 2017 at 04:07:59PM -0400, Willem de Bruijn wrote:
>> From: Willem de Bruijn <willemb@google.com>
>>
>> Implement a mechanism to signal that a virtio device implements the
>> VIRTIO_CONFIG_S_NEEDS_RESET command.
>>
>> Testing for VIRTIO_CONFIG_S_NEEDS_RESET support by issuing the request
>> and verifying the reset state would require an expensive state change.
>>
>> To avoid that, add a status bit to the feature register used during
>> feature negotiation between host and guest.
>>
>> Set the bit for virtio-net, which supports the feature.
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>
> All virtio 1 devices have the reset feature

I don't quite follow. No device drivers implement this request currently?

> so maybe guest does
> not need this flag. Does device need it? Does device really
> care that guest can't recover?

If all device drivers support it, then the flag is not needed.

But as long as legacy device drivers can exist that do not support
this feature, it has to have a way of differentiating between the two.
