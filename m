From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net/sched: CAN Filter/Classifier
Date: Tue, 05 Jun 2012 10:09:58 +0200
Message-ID: <1338883798.2760.2043.camel@edumazet-glaptop>
References: <1338826176-11646-1-git-send-email-lisovy@gmail.com>
	 <1338826176-11646-2-git-send-email-lisovy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	lartc@vger.kernel.org, pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Rostislav Lisovy <lisovy@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1338826176-11646-2-git-send-email-lisovy@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-06-04 at 18:09 +0200, Rostislav Lisovy wrote:
> This classifier classifies CAN frames (AF_CAN) according to their
> identifiers. This functionality can not be easily achieved with
> existing classifiers, such as u32. This classifier can be used
> with any available qdisc and it is able to classify both SFF
> or EFF frames.
> 
> The filtering rules for EFF frames are stored in an array, which
> is traversed during classification. A bitmap is used to store SFF
> rules -- one bit for each ID.
> 
> More info about the project:
> http://rtime.felk.cvut.cz/can/socketcan-qdisc-final.pdf
> 
> Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>
> ---
>  net/sched/Kconfig   |   10 +
>  net/sched/Makefile  |    1 +
>  net/sched/cls_can.c |  572 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 583 insertions(+)
>  create mode 100644 net/sched/cls_can.c

It seems a huge amount of code, and before reviewing it I would like to
ask :

1) Did you try to extend cls_flow somehow ?

2) Adding a cls_filter (or extend cls_flow to be able to use a bpf),
could be more generic, and thanks to bpf jit could be way faster.

3) sfq/fq_codel could be CAN aware if you adapt skb_flow_dissect() ?




