From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] net: sched: do not requeue a NULL skb
Date: Mon, 11 Apr 2016 08:52:31 -0700
Message-ID: <1460389951.6473.555.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460355869-13539-1-git-send-email-larper@axis.com>
		 <1460380981.6473.544.camel@edumazet-glaptop3.roam.corp.google.com>
		 <570BA8C7.1000905@axis.com>
	 <1460384551.6473.551.camel@edumazet-glaptop3.roam.corp.google.com>
	 <570BC024.1070504@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lars Persson <larper@axis.com>, netdev@vger.kernel.org,
	jhs@mojatatu.com, linux-kernel@vger.kernel.org,
	xiyou.wangcong@gmail.com
To: Lars Persson <lars.persson@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570BC024.1070504@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-04-11 at 17:17 +0200, Lars Persson wrote:
> 
> On 04/11/2016 04:22 PM, Eric Dumazet wrote:
> > On Mon, 2016-04-11 at 15:38 +0200, Lars Persson wrote:
> >
> >> I though it would be prudent because the queue can be non-empty even for
> >> the case of skb=NULL. So should it be there in this patch, another patch
> >> or not at all ?
> >
> > Then maybe change return code ?
> >
> > It seems strange that a validate_xmit_skb_list() failure stops the
> > __qdisc_run() loop but schedules another round.
> >
> >
> 
> It was suggested by Cong Wang to return 0 in order to stop the loop. Do 
> you guys agree that the loop should be stopped for such failures ? Then 
> I will put the schedule call inside the if as you proposed earlier.

What are the causes of validate_xmit_skb_list() failures ?

If gso segmentations fail because of memory pressure, better free more
skbs right now.

In any case, having a single test " if (skb)  " sounds better to me,
to have a fast path.

So your first patch was probably a better idea.

v2 has two tests instead of one.
