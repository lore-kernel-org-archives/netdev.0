From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] net: sched: do not requeue a NULL skb
Date: Mon, 11 Apr 2016 16:48:59 -0700
Message-ID: <1460418539.6473.583.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460355869-13539-1-git-send-email-larper@axis.com>
	 <1460380981.6473.544.camel@edumazet-glaptop3.roam.corp.google.com>
	 <570BA8C7.1000905@axis.com>
	 <1460384551.6473.551.camel@edumazet-glaptop3.roam.corp.google.com>
	 <570BC024.1070504@axis.com>
	 <1460389951.6473.555.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpWM0cce9PtvkenywGpvh0MEMe_0qvkKC00kYFAdFG=BxQ@mail.gmail.com>
	 <1460399171.6473.562.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1460399456.6473.566.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpVid8=LeO31p_ZiPQkhWtgCuioUzfCdgDPatFxkWrkbCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lars Persson <lars.persson@axis.com>,
	Lars Persson <larper@axis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVid8=LeO31p_ZiPQkhWtgCuioUzfCdgDPatFxkWrkbCg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-04-11 at 16:19 -0700, Cong Wang wrote:

> My point is, for example, in OOM case, we don't know processin
> more SKB would make it better or worse. Maybe we really need to
> check the error code to decide to continue to exit?

Really, given this bug has been there for a long time (v3.18 ???), I
doubt it matters.

Nothing can tell that following packets in the qdisc need any
transformation, and memory allocations.

So I would just fix the bug in the simplest way.

__qdisc_run() has all the checks needed to yield when needed 
(if (quota <= 0 || need_resched())) , no need to add more complexity
there.
