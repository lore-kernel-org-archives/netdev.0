From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio: Fix affinity for >32 VCPUs
Date: Fri, 3 Feb 2017 15:25:50 -0500
Message-ID: <CAF=yD-K3u0RqGXzyqEEm7hGm0cpKPXxQ_cjnDU33SxOwHiZ1-g@mail.gmail.com>
References: <20170203061905.100283-1-serebrin@google.com> <20170203170512-mutt-send-email-mst@kernel.org>
 <CAN+hb0VJKD7DwNTujL7k1E5_OQdaZbo5AugqW=_0c4MZoJ6=nA@mail.gmail.com>
 <CAF=yD-LWPoHuvbYRewALX65Y5zbSLDZb+ei2i53M=sSUDYZAuw@mail.gmail.com> <7651ccc0-9ef7-0419-93ae-47da1158c2d1@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benjamin Serebrin <serebrin@google.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        jasowang@redhat.com, David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Venkatesh Srinivas <venkateshs@google.com>,
        James Mattson <jmattson@google.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34720 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752073AbdBCU0c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 15:26:32 -0500
Received: by mail-wm0-f65.google.com with SMTP id c85so6789677wmi.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 12:26:31 -0800 (PST)
In-Reply-To: <7651ccc0-9ef7-0419-93ae-47da1158c2d1@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 1:34 PM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 02/03/2017 10:31 AM, Willem de Bruijn wrote:
>>
>> Configuring interrupts and xps from userspace at boot is more robust,
>> as device driver defaults can change. But especially for customers who
>> are unaware of these settings, choosing sane defaults won't hurt.
>
>
> The devil is in finding the sane defaults.

Agreed, of course.

>  For example, the issues we've
> seen with VMs sending traffic getting reordered when the driver took it upon
> itself to enable xps.

That particular reordering issue [1] was with xps on the host, where vm thread
migration causes flows to exit on different tx queues because ooo_okay is
not supported for flows from tap devices.

Within a guest, on the other hand, xps settings should not cause reordering of
packets from the same flow, as ooo_okay is active for tcp flows.

[1] https://patchwork.ozlabs.org/patch/662913/
