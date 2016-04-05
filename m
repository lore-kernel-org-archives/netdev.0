From: Eran Ben Elisha <eranlinuxmellanox@gmail.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Tue, 5 Apr 2016 21:59:31 +0300
Message-ID: <CAKHjkjmEwC=4WqqFkNJi8SUpQ4hFAob2PQY_EyYwYQwW=PcK9A@mail.gmail.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	<1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
	<1459562911.6473.299.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160403061536.GD21980@gmail.com>
	<20160405022004.GA7677@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	tom@herbertland.com, alexei.starovoitov@gmail.com,
	Or Gerlitz <ogerlitz@mellanox.com>, daniel@iogearbox.net,
	john.fastabend@gmail.com, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33737 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbcDES7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 14:59:33 -0400
Received: by mail-wm0-f67.google.com with SMTP id i204so6941578wmd.0
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 11:59:32 -0700 (PDT)
In-Reply-To: <20160405022004.GA7677@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 5, 2016 at 5:20 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> On Sat, Apr 02, 2016 at 11:15:38PM -0700, Brenden Blanco wrote:
>> On Fri, Apr 01, 2016 at 07:08:31PM -0700, Eric Dumazet wrote:
> [...]
>> > 2) priv->stats.rx_dropped is shared by all the RX queues -> false
>> > sharing.
>> >
>> >    This is probably the right time to add a rx_dropped field in struct
>> > mlx4_en_rx_ring since you guys want to drop 14 Mpps, and 50 Mpps on
>> > higher speed links.
>> >
>> This sounds reasonable! Will look into it for the next spin.
> I looked into this, and it seems to me that both the rx and tx dropped
> stats are buggy. With commit a3333b35da1634f49aca541f2574a084221e2616,
> specifically with the line
>   stats->rx_dropped = be32_to_cpu(mlx4_en_stats->RDROP);
> that occurs during the periodic ethtool task, whatever ++ was happening
> in the rx/tx code is overwritten with the HW value. Since the SW stats
> are incremented mostly in edge (oom) cases, nobody probably noticed. To
> me it doesn't seem right to mix hard and soft counters, especially at
> the risk of making a bad situation worse, so I'm planning to omit the
> new bpf dropped++ stat and we can discuss ways to fix this other bug
> separately.

Thanks Eric and Brenden,
I will make a patch for mlx4_en RX dropped counters to fix the issues
you raised here.
