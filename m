From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH iproute2] ss: Show more info (ring,fanout) for packet socks
Date: Wed, 13 May 2015 17:10:38 -0400
Message-ID: <CA+FuTSeM_FQBRToXCBix9ns3_07ivfqxYHB4nGHcSqqp31fX5A@mail.gmail.com>
References: <1431509966-5054-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:32970 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964997AbbEMVLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 17:11:09 -0400
Received: by oica37 with SMTP id a37so41589510oic.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 14:11:08 -0700 (PDT)
In-Reply-To: <1431509966-5054-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +               }
> +               if (has_fanout) {
> +                       uint16_t type = (fanout >> 16) & 0xffff;

type can be modified by flags in the upper 8 bits. Better
mask those out and report them separately.

> +
> +                       printf("\n\tfanout(");
> +                       printf("id:%d,", fanout & 0xff);
> +                       printf("type:0x%x", type);
> +                       if (type == 0)
> +                               printf("(hash)");
> +                       else if (type == 1)
> +                               printf("(lb)");
> +                       else if (type == 2)
> +                               printf("(cpu)");
> +                       else if (type == 3)
> +                               printf("(rollover)");
> +                       else if (type == 4)
> +                               printf("(random)");
> +                       else if (type == 5)
> +                               printf("(qm)");
