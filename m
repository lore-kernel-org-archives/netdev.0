From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Sat, 29 Oct 2016 13:25:14 +0200
Message-ID: <20161029112514.GC1810@pox.localdomain>
References: <20161028011739-mutt-send-email-mst@kernel.org>
 <20161027.213512.334468356710231957.davem@davemloft.net>
 <CAKgT0Ufe3QYtFpmtsL39-nbyy+YEt=gZKU_WUr9Wir+LTYLuEQ@mail.gmail.com>
 <20161027.221027.109834362557507518.davem@davemloft.net>
 <58137533.4030105@gmail.com>
 <20161028171812.48073f1f@jkicinski-Precision-T1700>
 <20161028182223.GA53930@ast-mbp.thefacebook.com>
 <ec23c734c23d81884349484927140741@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jakub Kicinski <kubakici@wp.pl>,
        John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>, alexander.duyck@gmail.com,
        mst@redhat.com, brouer@redhat.com, shrijeet@gmail.com,
        tom@herbertland.com, netdev@vger.kernel.org,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35565 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754766AbcJ2LZR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 07:25:17 -0400
Received: by mail-wm0-f53.google.com with SMTP id e69so151907682wmg.0
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2016 04:25:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ec23c734c23d81884349484927140741@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/16 at 08:51pm, Shrijeet Mukherjee wrote:
> Generally agree, but SRIOV nics with multiple queues can end up in a bad
> spot if each buffer was 4K right ? I see a specific page pool to be used
> by queues which are enabled for XDP as the easiest to swing solution that
> way the memory overhead can be restricted to enabled queues and shared
> access issues can be restricted to skb's using that pool no ?

Isn't this clearly a must anyway? I may be missing something
fundamental here so please enlighten me :-)

If we dedicate a page per packet, that could translate to 14M*4K worth
of memory being mapped per second for just a 10G NIC under DoS attack.
How can one protect such as system? Is the assumption that we can always
drop such packets quickly enough before we start dropping randomly due
to memory pressure? If a handshake is required to determine validity
of a packet then that is going to be difficult.
