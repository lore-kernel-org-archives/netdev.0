From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/3] net: make default tx_queue_len configurable
Date: Wed, 12 Aug 2015 07:55:26 -0700
Message-ID: <1439391326.29802.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438203103-27013-2-git-send-email-phil@nwl.cc>
	 <20150729210618.GF32705@breakpoint.cc>
	 <20150729213428.GC15554@orbit.nwl.cc>
	 <20150729.143731.834219016906219771.davem@davemloft.net>
	 <20150811174807.3e00b4da@redhat.com> <20150811162335.GB32353@orbit.nwl.cc>
	 <20150812011347.GA58200@Alexeis-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, cwang@twopensource.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33257 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199AbbHLOz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 10:55:28 -0400
Received: by pabyb7 with SMTP id yb7so16150628pab.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 07:55:28 -0700 (PDT)
In-Reply-To: <20150812011347.GA58200@Alexeis-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-11 at 18:13 -0700, Alexei Starovoitov wrote:
> Also why introduce the flag? Why not just add 'tx_queue_len = 0;' 
> to veth_setup() like the whole bunch of devices do?

Sigh.

Because some people install htb or pfifo on veth, leaving tx_queue_len
unchanged.

If you install htb while tx_queue_len is 0, pfifo created on htb classe
can only queue one packet.


static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
{
        bool bypass;
        bool is_bfifo = sch->ops == &bfifo_qdisc_ops;

        if (opt == NULL) {
                u32 limit = qdisc_dev(sch)->tx_queue_len ? : 1;

                if (is_bfifo)
                        limit *= psched_mtu(qdisc_dev(sch));

                sch->limit = limit;



Changing veth txqueuelen is too late.
