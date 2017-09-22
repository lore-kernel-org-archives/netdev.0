From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH,v2,net-next 1/2] tun: enable NAPI for TUN/TAP driver
Date: Fri, 22 Sep 2017 14:03:05 -0400
Message-ID: <CAF=yD-Ldc_K+MTd_wXNjvvQ-+UsjZOs+13irmRoGJzJmq5yfVA@mail.gmail.com>
References: <20170922021715.2618-1-peterpenkov96@gmail.com>
 <20170922021715.2618-2-peterpenkov96@gmail.com> <CAF2d9jh=H1O4JR3u=Rs3ODuQRF-Qp2wzzhAVf3PQ_f_Ox98eKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Petar Penkov <peterpenkov96@gmail.com>,
        linux-netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>,
        Petar Bozhidarov Penkov <ppenkov@stanford.edu>
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:38519 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752259AbdIVSDq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 14:03:46 -0400
Received: by mail-io0-f195.google.com with SMTP id e9so100026iod.5
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 11:03:46 -0700 (PDT)
In-Reply-To: <CAF2d9jh=H1O4JR3u=Rs3ODuQRF-Qp2wzzhAVf3PQ_f_Ox98eKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 22, 2017 at 1:11 PM, Mahesh Bandewar (=E0=A4=AE=E0=A4=B9=E0=A5=
=87=E0=A4=B6 =E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE=E0=A4=
=B0)
<maheshb@google.com> wrote:
>>  #ifdef CONFIG_TUN_VNET_CROSS_LE
>>  static inline bool tun_legacy_is_little_endian(struct tun_struct *tun)
>>  {
>> @@ -541,6 +604,11 @@ static void __tun_detach(struct tun_file *tfile, bo=
ol clean)
>>
>>         tun =3D rtnl_dereference(tfile->tun);
>>
>> +       if (tun && clean) {
>> +               tun_napi_disable(tun, tfile);
> are we missing synchronize_net() separating disable and del calls?

That is not needed here. napi_disable has its own mechanism for waiting
until a napi struct is no longer run. netif_napi_del will call synchronize_=
net
if needed. These two calls are made one after the other in quite a few driv=
ers.
