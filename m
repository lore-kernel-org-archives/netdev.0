From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/8] flow_keys: Record IP layer protocol in
 skb_flow_dissect()
Date: Thu, 18 Sep 2014 07:38:00 -0700
Message-ID: <1411051080.7106.259.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com>
	 <1402338773-5996-2-git-send-email-_govind@gmx.com>
	 <CAE9FiQW+Rv4o9Pc1J9hyqgW1WrhEANKEXH6zYQc2NQqeMbAcvA@mail.gmail.com>
	 <alpine.LNX.2.03.1406261159071.1438@ws.cisco>
	 <CAJZOPZJ7+n0t1LCqaa3JCBByRw=f_Tp6rk8vm0ZnCzmtKFKX_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Govindarajulu Varadarajan <_govind@gmx.com>,
	Yinghai Lu <yinghai@kernel.org>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>, ssujith@cisco.com,
	gvaradar@cisco.com, "Christian Benvenuti (benve)" <benve@cisco.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:44912 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755855AbaIROiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 10:38:03 -0400
Received: by mail-pa0-f53.google.com with SMTP id rd3so1624408pab.12
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 07:38:02 -0700 (PDT)
In-Reply-To: <CAJZOPZJ7+n0t1LCqaa3JCBByRw=f_Tp6rk8vm0ZnCzmtKFKX_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-18 at 17:18 +0300, Or Gerlitz wrote:

> The crash happens 100% on IPoIB (IP-over-Infiniband) [1] interfaces
> b/c your upstream commit e0f31d8 "flow_keys: Record IP layer protocol
> in skb_flow_dissect()" causes the IPoIB data stashed on skb->cb [2] to
> smash other skb fields.
> 
> So your 3.17-rc1 commit introduced a regression to how things work
> since kernel 3.2
> 
> Can please see how to revert this hunk
> 
> -- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -231,7 +231,7 @@ struct qdisc_skb_cb {
>         unsigned int            pkt_len;
>         u16                     slave_dev_queue_mapping;
>         u16                     _pad;
> -       unsigned char           data[20];
> +       unsigned char           data[24];
>  };
> 
> thanks,
> 
> Or.
> 
> [1]  http://marc.info/?l=linux-rdma&m=141029109017035&w=2
> [2] see these commits
> 
> 936d7de3 IPoIB: Stop lying about hard_header_len and use skb->cb to
> stash LL addresses
> a0417fa3  net: Make qdisc_skb_cb upper size bound explicit

I am taking care of this right now guys.
