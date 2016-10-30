From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 2/2] net/mlx4_en: Refactor the XDP forwarding
 rings scheme
Date: Mon, 31 Oct 2016 01:11:34 +0200
Message-ID: <CALzJLG9HYriAiPE=M0+ObKNDFVKGfD6V63sGGDGa+JbhCjpKZQ@mail.gmail.com>
References: <1477579924-32737-1-git-send-email-tariqt@mellanox.com>
 <1477579924-32737-3-git-send-email-tariqt@mellanox.com> <20161028010701.GB49550@ast-mbp.thefacebook.com>
 <34ee2e3e-a2ad-2104-9444-ae9c7fed55b7@gmail.com> <20161030224434.GB6658@ast-mbp.hil-sfehihf.abq.wayport.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tariq Toukan <ttoukan.linux@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:35985 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756048AbcJ3XL5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 19:11:57 -0400
Received: by mail-lf0-f47.google.com with SMTP id t196so5547481lff.3
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 16:11:56 -0700 (PDT)
In-Reply-To: <20161030224434.GB6658@ast-mbp.hil-sfehihf.abq.wayport.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 12:44 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Sun, Oct 30, 2016 at 06:03:06PM +0200, Tariq Toukan wrote:
>>
>> Note that the XDP TX rings are no longer shown in ethtool -S.
>
> ouch. Can you make it to show them as some large TX numbers instead?
> It would really sux to lose stats on them.
>

Right, Tariq, how did we miss this ?

FYI, I don't think we need the whole TX queue stats for XDP tx rings,
it is just an overkill, there are only two active counters for XDP TX
ring (XDP_TX_FWD/XDP_TX_DROP).

XDP_TX_FWD or currently "tx_packets" will count successfully forwarded packets
XDP_TX_DROP or currently "tx_dropped" will count TX dropped packets
due to full ring.

do we need tx_bytes as well ? I think yes.

The whole idea of this refactoring i.e. differentiating between TXQ
netdev rings and XDP TX rings, that XDP is a fast path with minimal
system overhead, we don't need to have the full set of regular TXQ
counters for XDP TX rings.
