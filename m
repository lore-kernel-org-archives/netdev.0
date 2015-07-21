From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH,v2 net] net: sched: validate that class is found in
 qdisc_tree_decrease_qlen
Date: Tue, 21 Jul 2015 22:57:51 +0200
Message-ID: <1437512271.9913.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1437421248-2796139-1-git-send-email-agartrell@fb.com>
	 <55AE1939.105@mojatatu.com>
	 <1437475945.9913.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpWWzMFLuLsJZD4rJLW7rNWNOEotrjj7o4Z+0Pr330M2Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alex Gartrell <agartrell@fb.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	kernel-team@fb.com, stable@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpWWzMFLuLsJZD4rJLW7rNWNOEotrjj7o4Z+0Pr330M2Fw@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-07-21 at 11:12 -0700, Cong Wang wrote:

> > -               kfree_skb(skb);
> > +       INIT_LIST_HEAD(&q->new_flows);
> > +       INIT_LIST_HEAD(&q->old_flows);
> > +       for (i = 0; i < q->flows_cnt; i++) {
> > +               struct fq_codel_flow *flow = q->flows + i;
> > +
> > +               while (flow->head)
> > +                       kfree_skb(dequeue_head(flow));
> > +
> > +               INIT_LIST_HEAD(&flow->flowchain);
> 
> 
> You probably need to call codel_vars_init(&flow->cvars) as well.

It is not necessary : flow->cvars only matter in the event of a dequeue,
but whole qdisc is dismantled and no packet will be dequeued.
