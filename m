From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Mon, 26 Sep 2016 19:54:37 -0600
Message-ID: <fd77837c-433c-5010-7d07-68b0bf3e3d22@cumulusnetworks.com>
References: <999f0ddb-82e4-ea07-b52a-59d08bc7816d@cumulusnetworks.com>
 <20160916070623.GD1867@uranus.lan> <20160916190000.GA18116@uranus.lan>
 <59e12627-7043-fd20-0d68-899ab43b0e71@cumulusnetworks.com>
 <20160916193927.GB18116@uranus.lan>
 <d943c6b7-0f06-3823-58d2-6f79f17c3d59@cumulusnetworks.com>
 <20160916195252.GC18116@uranus.lan>
 <6464ac16-a15b-384e-ffb1-3ee84cdce313@cumulusnetworks.com>
 <20160916200722.GA26044@uranus.lan> <20160920211343.GI26044@uranus.lan>
 <20160926223828.GL1876@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: Cyrill Gorcunov <gorcunov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33330 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933035AbcI0Byk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 21:54:40 -0400
Received: by mail-pf0-f177.google.com with SMTP id 21so71593100pfy.0
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 18:54:40 -0700 (PDT)
In-Reply-To: <20160926223828.GL1876@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/26/16 4:38 PM, Cyrill Gorcunov wrote:
> Something like
> 
> Index: linux-ml.git/include/uapi/linux/inet_diag.h
> ===================================================================
> --- linux-ml.git.orig/include/uapi/linux/inet_diag.h    2016-09-11 20:56:18.191584145 +0300
> +++ linux-ml.git/include/uapi/linux/inet_diag.h 2016-09-27 01:34:08.413172394 +0300
> @@ -38,7 +38,7 @@ struct inet_diag_req_v2 {
>         __u8    sdiag_family;
>         __u8    sdiag_protocol;
>         __u8    idiag_ext;
> -       __u8    pad;
> +       __u8    sdiag_raw_protocol;     /* SOCK_RAW only, @pad for others */

Seems like that should be a union to keep the API.


>         __u32   idiag_states;
>         struct inet_diag_sockid id;
>  };
> 
> and in raw-diag module we will use @sdiag_raw_protocol instead of
> @sdiag_protocol field. Didn't cover ss tool source code yet but
> I think the idea is seen. Still not sure if start using @pad here
> is a good idea (it's uapi), maybe beter to ask nla attribute which would
> come right afterh the inet_diag_req_v2 message?
> 

seems reasonable to me since 2 protocols need to be sent to the kernel.

Alternatively, sdiag_protocol could be the actual protocol and the pad union be a flag field with say bit 0 = INET_DIAG_FLAG_SOCK_RAW. Allows other overrides in the future if needed.
