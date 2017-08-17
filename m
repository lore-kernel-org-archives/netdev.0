From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCHv2 net-next iproute2] gre: add support for ERSPAN tunnel
Date: Thu, 17 Aug 2017 15:31:28 -0700
Message-ID: <CALDO+SaAyNG0RfZPkA+hTYAx3P_JtJ5Ah3sj2GKE1oDjXnTLUw@mail.gmail.com>
References: <1502396067-21274-1-git-send-email-u9012063@gmail.com> <20170810151213.095a4505@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Meenakshi Vohra <mvohra@vmware.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:38223 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753310AbdHQWcJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 18:32:09 -0400
Received: by mail-it0-f67.google.com with SMTP id f16so4987661itb.5
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 15:32:09 -0700 (PDT)
In-Reply-To: <20170810151213.095a4505@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +             if (greinfo[IFLA_GRE_ERSPAN_INDEX])
>> +                     erspan_idx = rta_getattr_u32(greinfo[IFLA_GRE_ERSPAN_INDEX]);
>>       }
>
> Are you missing a ntohl() here?

>
> It is encoded as htonl() when sending to kernel.
>
>                 addattr32(n, 1024, IFLA_GRE_FWMARK, fwmark);
> +               addattr32(n, 1024, IFLA_GRE_ERSPAN_INDEX, htonl(erspan_idx));
Thanks for the feedbacks, and sorry for my late response.

Now I plan to not translate to network-byte order, but do it inside
the kernel. So kernel expects host order, ip route only sends
host-byte order.

>
> Is erspan_idx == 0 a reserved value?
ERSPAN spec does not say erspan_idx = 0 should be reserved or not. But
I assume at lease people will put some value, so I assume it is
reserved. And only when it is non-zero, then send to kernel.

> You should only send erspan_idx to kernel if it is given on command line.
Yes, I will resubmit next patch.

Regards,
William
