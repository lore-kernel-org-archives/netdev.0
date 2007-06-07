From: "kalash nainwal" <kalash.nainwal@gmail.com>
Subject: Re: extra layer below inet layer.
Date: Thu, 7 Jun 2007 16:00:33 +0530
Message-ID: <416aa1ad0706070330i12fe211dn25cd2d174f3a7100@mail.gmail.com>
References: <2bd9ebfa0706062140vfddf3etfc8fd17749c9ad12@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Tej Parkash" <tejparkash.d@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.180]:15221 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbXFGKaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 06:30:35 -0400
Received: by ik-out-1112.google.com with SMTP id b32so390130ika
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 03:30:33 -0700 (PDT)
In-Reply-To: <2bd9ebfa0706062140vfddf3etfc8fd17749c9ad12@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/7/07, Tej Parkash <tejparkash.d@gmail.com> wrote:
> hi
>
> i just want to have something like tcp layer sitting below inet layer.
> so that i can directly offload everything to NIC
> and i want it to be placed dynamically. so depending on the nic i can
> offload the feature or can make it normal flow.
> i.e. both layer should exist and normal functionality should not break.
>
> this code is in af_inet.c
>
> static struct inet_protosw inetsw_array[] =
> {
>        {
>                .type =       SOCK_STREAM,
>                .protocol =   IPPROTO_TCP,
>                .prot =       &tcp_prot,
>                .ops =        &inet_stream_ops,
>                .capability = -1,
>                .no_check =   0,
>                .flags =      INET_PROTOSW_PERMANENT |
>                              INET_PROTOSW_ICSK,
>        },
>
>        {
>                .type =       SOCK_DGRAM,
>                .protocol =   IPPROTO_UDP,
>                .prot =       &udp_prot,
>                .ops =        &inet_dgram_ops,
>                .capability = -1,
>                .no_check =   UDP_CSUM_DEFAULT,
>                .flags =      INET_PROTOSW_PERMANENT,
>       },
>
>
>       {
>               .type =       SOCK_RAW,
>               .protocol =   IPPROTO_IP,        /* wild card */
>               .prot =       &raw_prot,
>               .ops =        &inet_sockraw_ops,
>               .capability = CAP_NET_RAW,
>               .no_check =   UDP_CSUM_DEFAULT,
>               .flags =      INET_PROTOSW_REUSE,
>       }
> };
>
> i was just going through the code i found that if i can regsiter above
> kind of registration dynamically i will be able to do that.
> i have tried to do that but since normal tcp registered this at boot
> up time i am not able to unregister this dynamically
>
> so is it possible to unregister tcp and register my protocol dynamically.

inet_unregister_protosw()/inet_register_protosw().

-Kalash
