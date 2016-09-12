From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3 2/3] e1000: add initial XDP support
Date: Mon, 12 Sep 2016 16:46:08 -0700
Message-ID: <1473723968.18970.111.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160912220312.5610.77528.stgit@john-Precision-Tower-5810>
         <20160912221351.5610.29043.stgit@john-Precision-Tower-5810>
         <1473720399.18970.91.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160912230745.GA24171@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, bblanco@plumgrid.com,
        jeffrey.t.kirsher@intel.com, brouer@redhat.com,
        davem@davemloft.net, xiyou.wangcong@gmail.com,
        intel-wired-lan@lists.osuosl.org, u9012063@gmail.com,
        netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33405 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751420AbcILXqK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 19:46:10 -0400
Received: by mail-pf0-f169.google.com with SMTP id g202so57268978pfb.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 16:46:10 -0700 (PDT)
In-Reply-To: <20160912230745.GA24171@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-12 at 16:07 -0700, Alexei Starovoitov wrote:

> yep. there are various ways to shoot yourself in the foot with xdp.
> The simplest program that drops all the packets will make the box unpingable.

Well, my comment was about XDP_TX only, not about XDP_DROP or driving a
scooter on 101 highway ;)

This XDP_TX thing was one of the XDP marketing stuff, but there is
absolutely no documentation on it, warning users about possible
limitations/outcomes.

BTW, I am not sure mlx4 implementation even works, vs BQL :

mlx4_en_xmit_frame() does not call netdev_tx_sent_queue(),
but tx completion will call netdev_tx_completed_queue() -> crash

Do we have one test to validate that a XDP_TX implementation is actually
correct ?
