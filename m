From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/2] net: sched: make default fifo qdiscs appear in
 the dump
Date: Wed, 08 Mar 2017 07:17:59 -0800
Message-ID: <1488986279.28631.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LSU.2.20.1703081302240.31814@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Phil Sutter <phil@nwl.cc>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.20.1703081302240.31814@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-03-08 at 13:03 +0100, Jiri Kosina wrote:


> +++ b/net/sched/sch_qfq.c
> @@ -494,6 +494,8 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
>  			goto destroy_class;
>  	}
>  
> +	if (cl->qdisc != &noop_qdisc)
> +		qdisc_hash_add(cl->qdisc, true);


Please move the test in qdisc_hash_add() instead of copy/pasting it all
over the places ?

This is control path, keep it small, thanks !
