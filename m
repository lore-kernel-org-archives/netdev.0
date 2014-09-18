From: Doug Ledford <dledford@xsintricity.com>
Subject: Re: [net] net: sched: shrink struct qdisc_skb_cb to 28 bytes
Date: Thu, 18 Sep 2014 18:29:31 -0400
Message-ID: <541B5CCB.6060808@xsintricity.com>
References: <1411052525.7106.269.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Govindarajulu Varadarajan <_govind@gmx.com>,
	Yinghai Lu <yinghai@kernel.org>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>, ssujith@cisco.com,
	gvaradar@cisco.com, "Christian Benvenuti (benve)" <benve@cisco.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtpa11-05.prod.phx3.secureserver.net ([68.178.252.106]:59834
	"EHLO p3plsmtpa11-05.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751978AbaIRWh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 18:37:26 -0400
In-Reply-To: <1411052525.7106.269.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2014 11:02 AM, Eric Dumazet wrote:
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
> Fixes: e0f31d849867 ("flow_keys: Record IP layer protocol in skb_flow_dissect()")

I've installed this patch on my cluster and it resolves the problem.

Tested-by/Acked-by: Doug Ledford <dledford@redhat.com>
