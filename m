From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Fri, 21 Dec 2012 07:45:20 -0800
Message-ID: <1356104720.21834.7497.camel@edumazet-glaptop>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com>
	 <50CCE961.5050204@mojatatu.com>
	 <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr>
	 <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com>
	 <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com>
	 <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr>
	 <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com>
	 <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com>
	 <50D06177.2090905@mojatatu.com>
	 <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com>
	 <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com>
	 <50D2D229.6040802@gmail.com> <50D305FD.7000901@mojatatu.com>
	 <50D327CD.3050904@gmail.com> <50D45E25.7050703@mojatatu.com>
	 <50D46060.2070308@gmail.com> <50D46928.9070809@mojatatu.com>
	 <alpine.LNX.2.01.1212211533360.957@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Yury Stankevich <urykhy@gmail.com>,
	Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:63450 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159Ab2LUPpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 10:45:24 -0500
In-Reply-To: <alpine.LNX.2.01.1212211533360.957@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 15:35 +0100, Jan Engelhardt wrote:

> 
> The bigger problem here, if I see __netif_receive_skb right, is that
> when ingress rules run, skb->nfct is still unset, thereby the
> CONNMARK action is a no-op.

Right, ingress is performed before IP/netfilter stack.

This reminds me this might be the reason we have
skb_reset_transport_header(skb);
in __netif_receive_skb(), while its not very logical.

(Yes, sorry for being off topic, but I am referring to 
http://www.spinics.net/lists/netdev/msg214662.html )
