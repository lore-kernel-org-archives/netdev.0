From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Sat, 22 Dec 2012 14:43:14 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212221430280.9993@nerf07.vanv.qr>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com>
 <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com> <50D06177.2090905@mojatatu.com>
 <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com> <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com> <50D2D229.6040802@gmail.com> <50D305FD.7000901@mojatatu.com> <50D327CD.3050904@gmail.com> <50D45E25.7050703@mojatatu.com>
 <50D46060.2070308@gmail.com> <50D46928.9070809@mojatatu.com> <50D46EC1.2040608@gmail.com> <50D5B366.30005@mojatatu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Yury Stankevich <urykhy@gmail.com>,
	Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50D5B366.30005@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Saturday 2012-12-22 14:19, Jamal Hadi Salim wrote:
>
> Having said that, what you are doing sounds so useful
> that we need to make it work ;-> But it appears like
> we need a brand new action for it, something like
> GetMarkFromConntrack. Jan, I am assuming (on ingress only)
> we need to call "something" to give us the nfct then
> grab the skb->mark from nfct.

Looking up CT before ingress would mean the entire "raw"
table needs to be moved before ingress. But with classic
ip_tables, calling a table requires a lot of setup
(basically ip_rcv).

> On egress,
> I am assuming the skb->mark is already set if connmark
> is to be used... Am i correct?

All new skbs (i.e. those that did not loop due to IPsec, for example)
received through __netif_receive_skb should start out with
skb->mark=0, which is why CONNMARK --restore-mark is needed
to copy skb->mark=ct->mark.
