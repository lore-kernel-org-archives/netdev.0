From: Yury Stankevich <urykhy@gmail.com>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Thu, 20 Dec 2012 12:54:01 +0400
Message-ID: <50D2D229.6040802@gmail.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com> <50D06177.2090905@mojatatu.com> <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com> <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jan Engelhardt <jengelh@inai.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50D1AB7E.5060000@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

19.12.2012 15:56, Jamal Hadi Salim =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Hasan/Yury, if you test this please use the latest iproute2 with only
> the first patch I posted (originally from Hasan). Hasan please use th=
at
> patch not your version - if theres anything wrong we can find out soo=
ner
> before the patch becomes final.

Hello,
3.7.1 kernel with 3.7.0 iproute,
patch-xt, xt-p1 + linkage fix was applyed
command successfully performed, but actually doesn't work.

command:
tc filter add dev $dev parent ffff: protocol ip u32 match u32 0 0 \
            action xt -j CONNMARK --restore-mark \
            action mirred egress redirect dev ifb0
then i use filter:

tc filter add dev ifb0 protocol ip parent 1: prio 2 handle 0xa fw flowi=
d
1:102

iptables line:
iptable -t mangle -A POSTROUTING -p tcp --dport 80 -m connmark --mark 0
-m connbytes --connbytes 204800: --connbytes-dir both --connbytes-mode
bytes -j CONNMARK --set-mark 0xa

once i run a test to download 300K file,
from iptables counters i can see that rule in POSTROUTING is triggered,
but from `tc -s qdisc show dev ifb0` i see that no packets was sent to
1:102 flow.

btw,
tc -p -s filter show dev ifb0 parent 1:
do not show stats `(rule hit 416 success 0)` for this (filter protocol
ip pref 2 fw handle 0xa classid 1:102) rule.



--=20
Linux registered user #402966 // pub 1024D/E99AF373 <pgp.mit.edu>
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
