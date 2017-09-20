From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH,net-next,2/2] tun: enable napi_gro_frags() for TUN/TAP
 driver
Date: Tue, 19 Sep 2017 20:16:13 -0700
Message-ID: <1505877373.29839.81.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170919073402.2292-1-peterpenkov96@gmail.com>
         <20170919073402.2292-3-peterpenkov96@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Willem de Bruijn <willemb@google.com>, davem@davemloft.net,
        ppenkov@stanford.edu
To: Petar Penkov <peterpenkov96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:43629 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdITDQP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 23:16:15 -0400
Received: by mail-pf0-f180.google.com with SMTP id y29so874020pff.0
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 20:16:15 -0700 (PDT)
In-Reply-To: <20170919073402.2292-3-peterpenkov96@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-09-19 at 00:34 -0700, Petar Penkov wrote:
> Add a TUN/TAP receive mode that exercises the napi_gro_frags()
> interface. This mode is available only in TAP mode, as the interface
> expects packets with Ethernet headers.
> 
> Furthermore, packets follow the layout of the iovec_iter that was
> received. The first iovec is the linear data, and every one after the
> first is a fragment. If there are more fragments than the max number,
> drop the packet. Additionally, invoke eth_get_headlen() to exercise flow
> dissector code and to verify that the header resides in the linear data.
> 
> The napi_gro_frags() mode requires setting the IFF_NAPI_FRAGS option.
> This is imposed because this mode is intended for testing via tools like
> syzkaller and packetdrill, and the increased flexibility it provides can
> introduce security vulnerabilities.
> 
> Signed-off-by: Petar Penkov <peterpenkov96@gmail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: davem@davemloft.net
> Cc: ppenkov@stanford.edu
> ---

Again, very nice, thanks a lot Petar.

Acked-by: Eric Dumazet <edumazet@google.com>
