From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Sat, 22 Dec 2012 08:56:19 -0500
Message-ID: <50D5BC03.3070600@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com> <50D06177.2090905@mojatatu.com> <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com> <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com> <50D2D229.6040802@gmail.com> <50D305FD.7000901@mojatatu.com> <50D327CD.3050904@gmail.com> <50D45E25.7050703@mojatatu.com> <50D46060.2070308@gmail.com> <50D4692
 8.9070809@mojatatu.com> <50D46EC1.2040608@gmail.com> <50D5B366.30005@mojatatu.com> <alpine.LNX.2.01.1212221430280.9993@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yury Stankevich <urykhy@gmail.com>,
	Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f176.google.com ([209.85.210.176]:56749 "EHLO
	mail-ia0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113Ab2LVN4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2012 08:56:21 -0500
Received: by mail-ia0-f176.google.com with SMTP id y26so4748197iab.35
        for <netdev@vger.kernel.org>; Sat, 22 Dec 2012 05:56:21 -0800 (PST)
In-Reply-To: <alpine.LNX.2.01.1212221430280.9993@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-12-22 08:43 AM, Jan Engelhardt wrote:

>
> Looking up CT before ingress would mean the entire "raw"
> table needs to be moved before ingress. But with classic
> ip_tables, calling a table requires a lot of setup
> (basically ip_rcv).

Scanning the code:
Would it not work if i only passed it IP packets (the tc
classifier can check) and then for v4 i do something like
ipv4_conntrack_in() with pre-routing as the hook to update
the skb?

> All new skbs (i.e. those that did not loop due to IPsec, for example)
> received through __netif_receive_skb should start out with
> skb->mark=0, which is why CONNMARK --restore-mark is needed
> to copy skb->mark=ct->mark.

I  may be overthinking this: are you saying connmark should do the
copying to skb->mark instead of some action? Earlier you said
conmark depends on presence of skb->nfct.

cheers,
jamal
