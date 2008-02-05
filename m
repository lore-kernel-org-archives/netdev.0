From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET_SCHED] Add #ifdef CONFIG_NET_EMATCH in
 net/sched/cls_flow.c (latest git broken build)
Date: Tue, 05 Feb 2008 02:57:15 -0800 (PST)
Message-ID: <20080205.025715.84832892.davem@davemloft.net>
References: <eb3ff54b0802030051x604c991fwe11184e25d0a7550@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39990
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754544AbYBEK4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 05:56:47 -0500
In-Reply-To: <eb3ff54b0802030051x604c991fwe11184e25d0a7550@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Sun, 3 Feb 2008 10:51:42 +0200

> The 2.6 latest git build was broken when using the following
> configuration options:
> CONFIG_NET_EMATCH=n
> CONFIG_NET_CLS_FLOW=y
> 
> with the following error:
> net/sched/cls_flow.c: In function 'flow_dump':
> net/sched/cls_flow.c:598: error: 'struct tcf_ematch_tree' has no
> member named 'hdr'
> make[2]: *** [net/sched/cls_flow.o] Error 1
> make[1]: *** [net/sched] Error 2
> make: *** [net] Error 2
> 
> 
> see the recent post by Li Zefan:
>   http://www.spinics.net/lists/netdev/msg54434.html
> 
> The reason for this crash is that struct tcf_ematch_tree (net/pkt_cls.h) is
> empty when CONFIG_NET_EMATCH is not defined.
> 
> When CONFIG_NET_EMATCH is defined, the tcf_ematch_tree structure indeed holds
> a struct tcf_ematch_tree_hdr (hdr) as flow_dump() expects.
> 
> This patch adds #ifdef CONFIG_NET_EMATCH in flow_dump to avoid this.
>
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
