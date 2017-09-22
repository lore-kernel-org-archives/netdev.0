From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH,v2,net-next 1/2] tun: enable NAPI for TUN/TAP driver
Date: Fri, 22 Sep 2017 10:11:00 -0700
Message-ID: <CAF2d9jh=H1O4JR3u=Rs3ODuQRF-Qp2wzzhAVf3PQ_f_Ox98eKQ@mail.gmail.com>
References: <20170922021715.2618-1-peterpenkov96@gmail.com> <20170922021715.2618-2-peterpenkov96@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>,
        Petar Bozhidarov Penkov <ppenkov@stanford.edu>
To: Petar Penkov <peterpenkov96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:46315 "EHLO
        mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752020AbdIVRLV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 13:11:21 -0400
Received: by mail-yw0-f180.google.com with SMTP id v72so1182057ywa.3
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 10:11:21 -0700 (PDT)
In-Reply-To: <20170922021715.2618-2-peterpenkov96@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  #ifdef CONFIG_TUN_VNET_CROSS_LE
>  static inline bool tun_legacy_is_little_endian(struct tun_struct *tun)
>  {
> @@ -541,6 +604,11 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
>
>         tun = rtnl_dereference(tfile->tun);
>
> +       if (tun && clean) {
> +               tun_napi_disable(tun, tfile);
are we missing synchronize_net() separating disable and del calls?
> +               tun_napi_del(tun, tfile);
> +       }
> +
>         if (tun && !tfile->detached) {
>                 u16 index = tfile->queue_index;
>                 BUG_ON(index >= tun->numqueues);
