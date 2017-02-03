From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio: Fix affinity for >32 VCPUs
Date: Fri, 3 Feb 2017 13:31:36 -0500
Message-ID: <CAF=yD-LWPoHuvbYRewALX65Y5zbSLDZb+ei2i53M=sSUDYZAuw@mail.gmail.com>
References: <20170203061905.100283-1-serebrin@google.com> <20170203170512-mutt-send-email-mst@kernel.org>
 <CAN+hb0VJKD7DwNTujL7k1E5_OQdaZbo5AugqW=_0c4MZoJ6=nA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        jasowang@redhat.com, David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Venkatesh Srinivas <venkateshs@google.com>,
        James Mattson <jmattson@google.com>
To: Benjamin Serebrin <serebrin@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33912 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750995AbdBCScS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 13:32:18 -0500
Received: by mail-wm0-f67.google.com with SMTP id c85so6124723wmi.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 10:32:18 -0800 (PST)
In-Reply-To: <CAN+hb0VJKD7DwNTujL7k1E5_OQdaZbo5AugqW=_0c4MZoJ6=nA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> XPS settings aren't write-able from userspace, so the only way I know
> to fix XPS is in the driver.

It is writable by privileged users.

>> I wonder why not just do it in userspace though.

Configuring interrupts and xps from userspace at boot is more robust,
as device driver defaults can change. But especially for customers who
are unaware of these settings, choosing sane defaults won't hurt.

>> It would be nice to mention this in the commit log.
>> Are we sure this distribution is best for all workloads?

Overall, this minimizes contention between cores, so it should be
broadly preferable.
