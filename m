From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] net: sched: shrink struct qdisc_skb_cb to 28 bytes
Date: Thu, 18 Sep 2014 09:26:28 -0700
Message-ID: <20140918092628.566eae2b@urahara>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com>
	<1402338773-5996-2-git-send-email-_govind@gmx.com>
	<CAE9FiQW+Rv4o9Pc1J9hyqgW1WrhEANKEXH6zYQc2NQqeMbAcvA@mail.gmail.com>
	<alpine.LNX.2.03.1406261159071.1438@ws.cisco>
	<CAJZOPZJ7+n0t1LCqaa3JCBByRw=f_Tp6rk8vm0ZnCzmtKFKX_g@mail.gmail.com>
	<1411052525.7106.269.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Yinghai Lu <yinghai@kernel.org>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>, ssujith@cisco.com,
	gvaradar@cisco.com, "Christian Benvenuti (benve)" <benve@cisco.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:40155 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756556AbaIRQ0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 12:26:39 -0400
Received: by mail-pd0-f171.google.com with SMTP id y13so711204pdi.2
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 09:26:39 -0700 (PDT)
In-Reply-To: <1411052525.7106.269.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Sep 2014 08:02:05 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> We cannot make struct qdisc_skb_cb bigger without impacting IPoIB,
> or increasing skb->cb[] size.
> 
> Commit e0f31d849867 ("flow_keys: Record IP layer protocol in
> skb_flow_dissect()") broke IPoIB.
> 
> Only current offender is sch_choke, and this one do not need an
> absolutely precise flow key.
> 
> If we store 17 bytes of flow key, its more than enough. (Its the actual
> size of flow_keys if it was a packed structure, but we might add new
> fields at the end of it later)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Can we add BUILD_BUG to stop next time something smacks this.
