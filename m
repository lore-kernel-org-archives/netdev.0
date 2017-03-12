From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Sun, 12 Mar 2017 09:49:58 -0700
Message-ID: <1489337398.28631.58.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170213195858.5215-1-edumazet@google.com>
         <20170213195858.5215-9-edumazet@google.com>
         <1487780558.9415.81.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKgT0UcXhy3V_iSYFCWqPzdu77v=3-4FEXSyZEiUcB=Y_wGnVw@mail.gmail.com>
         <1487787706.9415.86.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKgT0Uda3Q6MTCdFf2eR_5Sw9KMTzGrnTosxh2iFT6Sn6QCwrw@mail.gmail.com>
         <1487815618.9415.101.camel@edumazet-glaptop3.roam.corp.google.com>
         <1489330636.28631.55.camel@edumazet-glaptop3.roam.corp.google.com>
         <1489332566.28631.57.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG-0V=o95so59ua34uNV8Zp_imYZxP883eXnsPg38f1mfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34923 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933837AbdCLQuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 12:50:02 -0400
Received: by mail-pg0-f65.google.com with SMTP id g2so11177885pge.2
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 09:50:01 -0700 (PDT)
In-Reply-To: <CALzJLG-0V=o95so59ua34uNV8Zp_imYZxP883eXnsPg38f1mfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-03-12 at 17:49 +0200, Saeed Mahameed wrote:
> On Sun, Mar 12, 2017 at 5:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Sun, 2017-03-12 at 07:57 -0700, Eric Dumazet wrote:
> >
> >> Problem is XDP TX :
> >>
> >> I do not see any guarantee mlx4_en_recycle_tx_desc() runs while the NAPI
> >> RX is owned by current cpu.
> >>
> >> Since TX completion is using a different NAPI, I really do not believe
> >> we can avoid an atomic operation, like a spinlock, to protect the list
> >> of pages ( ring->page_cache )
> >
> > A quick fix for net-next would be :
> >
> 
> Hi Eric, Good catch.
> 
> I don't think we need to complicate with an expensive spinlock,
>  we can simply fix this by not enabling interrupts on XDP TX CQ (not
> arm this CQ at all).
> and handle XDP TX CQ completion from the RX NAPI context, in a serial
> (Atomic) manner before handling RX completions themselves.
> This way locking is not required since all page cache handling is done
> from the same context (RX NAPI).
> 
> This is how we do this in mlx5, and this is the best approach
> (performance wise) since we dealy XDP TX CQ completions handling
> until we really need the space they hold (On new RX packets).

SGTM, can you provide the patch for mlx4 ?

Thanks !
