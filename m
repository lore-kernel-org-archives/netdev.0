From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: linux-next: net/sched/cls_flower.c
Date: Tue, 17 Oct 2017 12:21:07 +0200
Message-ID: <20171017102107.GF2112@nanopsycho>
References: <20171017101509.soy55d4ipx3dusbo@sirena.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Mark Brown <broonie@kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171017101509.soy55d4ipx3dusbo@sirena.co.uk>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Oct 17, 2017 at 12:15:09PM CEST, broonie@kernel.org wrote:
>Hi all,
>
>After merging the net-next tree, today's linux-next build
>(x86_allmodconfig) failed like this:
>
>/home/broonie/tmpfs/next/net/sched/cls_flower.c: In function 'fl_hw_destroy_filter':
>/home/broonie/tmpfs/next/net/sched/cls_flower.c:208:12: error: 'struct tc_cls_flower_offload' has no member named 'egress_dev'
>  cls_flower.egress_dev = f->hw_dev != tp->q->dev_queue->dev;
>            ^
>/home/broonie/tmpfs/next/net/sched/cls_flower.c:208:27: error: 'struct cls_fl_filter' has no member named 'hw_dev'
>  cls_flower.egress_dev = f->hw_dev != tp->q->dev_queue->dev;
>                           ^
>/home/broonie/tmpfs/next/net/sched/cls_flower.c: In function 'fl_hw_update_stats':
>/home/broonie/tmpfs/next/net/sched/cls_flower.c:270:12: error: 'struct tc_cls_flower_offload' has no member named 'egress_dev'
>  cls_flower.egress_dev = f->hw_dev != tp->q->dev_queue->dev;
>            ^
>/home/broonie/tmpfs/next/net/sched/cls_flower.c:270:27: error: 'struct cls_fl_filter' has no member named 'hw_dev'
>  cls_flower.egress_dev = f->hw_dev != tp->q->dev_queue->dev;

This fix ("net/sched: cls_flower: Set egress_dev mark when calling into the HW driver")
went to -net tree, should not go to -next. Apparently there is some mixup.
DaveM?


>                           ^
>/home/broonie/tmpfs/next/scripts/Makefile.build:319: recipe for target 'net/sched/cls_flower.o' failed
>
>Caused by commit
>
>  7578d7b45ed870b13a8ace57e32feaed623c2a94 ("net/sched: cls_flower: Set egress_dev mark when calling into the HW driver")
>
>interacting with 
>
>  7578d7b45ed870b1 ("net: sched: remove unused tcf_exts_get_dev helper and cls_flower->egress_dev")
>
>both in the net-next tree.  Falling back to previous net-next trees
>introduced other issues so I reverted that commit for today.
