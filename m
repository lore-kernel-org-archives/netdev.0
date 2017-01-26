From: Kaiwen Xu <kevin@kevxu.net>
Subject: Re: loopback device reference count leakage
Date: Thu, 26 Jan 2017 22:51:55 +0000
Message-ID: <CO2PR17MB01050D56F6EE3C8D54B00CAAA1770@CO2PR17MB0105.namprd17.prod.outlook.com>
References: <BY1PR17MB0101922AF9444B40E31B3B3CA1750@BY1PR17MB0101.namprd17.prod.outlook.com>
 <CAM_iQpXQ5MyL_KYNctZuZLv_w-ai3pmXKswOLXYeEYmVBdQqJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snt004-omc1s12.hotmail.com ([65.55.90.23]:51982 "EHLO
        SNT004-OMC1S12.hotmail.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752148AbdAZW56 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 17:57:58 -0500
In-Reply-To: <CAM_iQpXQ5MyL_KYNctZuZLv_w-ai3pmXKswOLXYeEYmVBdQqJA@mail.gmail.com>
Content-Language: en-US
Content-ID: <D1DC35F43938CE489BE63CB8F8F3DEF3@namprd17.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

I tested out your patch, it does seem to be preventing the issue from
happening. Here are the dev_put/dev_hold() calls with your patch
applied.

Jan 26 00:29:08 <hostname> kernel: [ 4385.940243] lo: dev_hold 1 rx_queue_add_kobject
Jan 26 00:29:08 <hostname> kernel: [ 4385.940255] lo: dev_hold 2 netdev_queue_add_kobject
Jan 26 00:29:08 <hostname> kernel: [ 4385.940257] lo: dev_hold 3 register_netdevice
Jan 26 00:29:08 <hostname> kernel: [ 4385.940260] lo: dev_hold 4 neigh_parms_alloc
Jan 26 00:29:08 <hostname> kernel: [ 4385.940262] lo: dev_hold 5 inetdev_init
Jan 26 00:29:08 <hostname> kernel: [ 4386.017699] lo: dev_hold 6 qdisc_alloc
Jan 26 00:29:08 <hostname> kernel: [ 4386.017741] lo: dev_hold 7 dev_get_by_index
Jan 26 00:29:08 <hostname> kernel: [ 4386.017749] lo: dev_hold 8 dev_get_by_index
Jan 26 00:29:08 <hostname> kernel: [ 4386.017756] lo: dev_hold 9 fib_check_nh
Jan 26 00:29:08 <hostname> kernel: [ 4386.017760] lo: dev_hold 10 fib_check_nh
Jan 26 00:29:08 <hostname> kernel: [ 4386.017767] lo: dev_hold 11 dev_get_by_index
Jan 26 00:29:08 <hostname> kernel: [ 4386.017772] lo: dev_hold 12 dev_get_by_index
Jan 26 00:29:08 <hostname> kernel: [ 4386.017775] lo: dev_hold 13 fib_check_nh
Jan 26 00:29:08 <hostname> kernel: [ 4386.017778] lo: dev_hold 14 fib_check_nh
Jan 26 00:29:08 <hostname> kernel: [ 4386.033548] lo: dev_put 14 free_fib_info_rcu
Jan 26 00:29:08 <hostname> kernel: [ 4386.033553] lo: dev_put 13 free_fib_info_rcu
Jan 26 00:29:08 <hostname> kernel: [ 4386.033556] lo: dev_put 12 free_fib_info_rcu
Jan 26 00:29:08 <hostname> kernel: [ 4386.033558] lo: dev_put 11 free_fib_info_rcu
Jan 26 00:29:08 <hostname> kernel: [ 4386.033560] lo: dev_put 10 free_fib_info_rcu
Jan 26 00:29:08 <hostname> kernel: [ 4386.033563] lo: dev_put 9 free_fib_info_rcu
Jan 26 00:29:09 <hostname> kernel: [ 4386.438175] lo: dev_hold 9 dst_init
Jan 26 00:29:09 <hostname> kernel: [ 4386.442558] lo: dev_hold 10 dst_init
Jan 26 00:29:09 <hostname> kernel: [ 4386.442564] lo: dev_hold 11 dst_init
Jan 26 00:29:09 <hostname> kernel: [ 4386.477575] lo: dev_put 11 dst_destroy
Jan 26 00:29:09 <hostname> kernel: [ 4386.641150] lo: dev_hold 11 dst_init
Jan 26 00:37:59 <hostname> kernel: [ 4916.949380] lo: dev_hold 12 dst_init
Jan 26 00:37:59 <hostname> kernel: [ 4916.949401] lo: dev_hold 13 __neigh_create
Jan 26 00:56:52 <hostname> kernel: [ 6049.882993] lo: dev_hold 14 dst_init
Jan 26 00:57:54 <hostname> kernel: [ 6111.782520] lo: dev_hold 15 dst_init
Jan 26 01:28:02 <hostname> kernel: [ 7920.396248] lo: dev_hold 16 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396251] lo: dev_hold 17 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396254] lo: dev_hold 18 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396257] lo: dev_hold 19 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396260] lo: dev_hold 20 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396263] lo: dev_hold 21 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396266] lo: dev_hold 22 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396268] lo: dev_hold 23 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396271] lo: dev_hold 24 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396274] lo: dev_hold 25 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396277] lo: dev_hold 26 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396280] lo: dev_hold 27 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396283] lo: dev_hold 28 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396286] lo: dev_hold 29 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396288] lo: dev_hold 30 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396291] lo: dev_hold 31 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396294] lo: dev_hold 32 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396297] lo: dev_hold 33 dst_ifdown
Jan 26 01:28:02 <hostname> kernel: [ 7920.396300] lo: dev_hold 34 dst_ifdown
Jan 26 01:28:03 <hostname> kernel: [ 7920.584272] lo: dev_put 34 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584277] lo: dev_put 33 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584279] lo: dev_put 32 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584281] lo: dev_put 31 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584283] lo: dev_put 30 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584285] lo: dev_put 29 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584287] lo: dev_put 28 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584289] lo: dev_put 27 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584290] lo: dev_put 26 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584301] lo: dev_put 25 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584303] lo: dev_put 24 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584305] lo: dev_put 23 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584307] lo: dev_put 22 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584309] lo: dev_put 21 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584311] lo: dev_put 20 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584324] lo: dev_put 19 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584326] lo: dev_put 18 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584328] lo: dev_put 17 dst_destroy
Jan 26 01:28:03 <hostname> kernel: [ 7920.584330] lo: dev_put 16 dst_destroy
Jan 26 01:30:32 <hostname> kernel: [ 8069.750192] lo: dev_put 15 neigh_destroy
Jan 26 01:30:32 <hostname> kernel: [ 8069.751961] lo: dev_put 14 qdisc_destroy
Jan 26 01:30:32 <hostname> kernel: [ 8069.752014] lo: dev_put 13 neigh_parms_release
Jan 26 01:30:32 <hostname> kernel: [ 8069.752055] lo: dev_put 12 rx_queue_release
Jan 26 01:30:32 <hostname> kernel: [ 8069.752069] lo: dev_put 11 netdev_queue_release
Jan 26 01:30:32 <hostname> kernel: [ 8069.752130] lo: dev_put 10 rollback_registered_many
Jan 26 01:30:32 <hostname> kernel: [ 8069.762072] lo: dev_put 9 free_fib_info_rcu
Jan 26 01:30:32 <hostname> kernel: [ 8069.766123] lo: dev_put 8 free_fib_info_rcu
Jan 26 01:30:32 <hostname> kernel: [ 8069.766127] lo: dev_put 7 dst_destroy
Jan 26 01:30:32 <hostname> kernel: [ 8069.766129] lo: dev_put 6 dst_destroy
Jan 26 01:30:32 <hostname> kernel: [ 8069.766132] lo: dev_put 5 dst_destroy
Jan 26 01:30:32 <hostname> kernel: [ 8069.766134] lo: dev_put 4 dst_destroy
Jan 26 01:30:32 <hostname> kernel: [ 8069.766135] lo: dev_put 3 dst_destroy
Jan 26 01:30:32 <hostname> kernel: [ 8069.766146] lo: dev_put 2 in_dev_finish_destroy
Jan 26 01:30:32 <hostname> kernel: [ 8069.766180] lo: dev_put 1 dst_ifdown

However, what confuses me is that when the issue didn't occur, there
were always multiple dst_ifdown() calls at the end continuously holding
and releasing the loopback device reference count (sometimes it will be
looping for about a minute), until the last dst_destroy() happens. E.g.

Jan 11 16:14:59 <hostname> kernel: [ 2033.429563] lo: dev_hold 2 dst_ifdown
Jan 11 16:14:59 <hostname> kernel: [ 2033.429565] lo: dev_put 2 dst_ifdown
Jan 11 16:15:00 <hostname> kernel: [ 2034.453484] lo: dev_hold 2 dst_ifdown
Jan 11 16:15:00 <hostname> kernel: [ 2034.453487] lo: dev_put 2 dst_ifdown

(this continues...)

Jan 11 16:15:01 <hostname> kernel: [ 2035.129452] lo: dev_put 1 dst_destroy

And when the issue did occur, the last dst_destroy() call never occurs.

I did some further digging, seems like the last dst_destroy() call is
trigger by dst_gc_task(). Here is the call trace (I added a dump_stack()
call to dst_destroy()).

Jan 19 19:44:00 <hostname> kernel: [ 1507.052752] Call Trace:
Jan 19 19:44:00 <hostname> kernel: [ 1507.052757]  [<ffffffff813be1cc>] dump_stack+0x63/0x87
Jan 19 19:44:00 <hostname> kernel: [ 1507.052759]  [<ffffffff816e1ea4>] dst_destroy+0x14/0x110
Jan 19 19:44:00 <hostname> kernel: [ 1507.052761]  [<ffffffff816e215c>] dst_gc_task+0x1bc/0x210
Jan 19 19:44:00 <hostname> kernel: [ 1507.052764]  [<ffffffff810b33d5>] ? put_prev_entity+0x35/0x670
Jan 19 19:44:00 <hostname> kernel: [ 1507.052767]  [<ffffffff81016656>] ? __switch_to+0x1d6/0x570
Jan 19 19:44:00 <hostname> kernel: [ 1507.052770]  [<ffffffff81095960>] process_one_work+0x150/0x3f0
Jan 19 19:44:00 <hostname> kernel: [ 1507.052772]  [<ffffffff810960da>] worker_thread+0x11a/0x470
Jan 19 19:44:00 <hostname> kernel: [ 1507.052776]  [<ffffffff817da0f9>] ? __schedule+0x359/0x980
Jan 19 19:44:00 <hostname> kernel: [ 1507.052778]  [<ffffffff81095fc0>] ? rescuer_thread+0x310/0x310
Jan 19 19:44:00 <hostname> kernel: [ 1507.052780]  [<ffffffff8109b969>] kthread+0xc9/0xe0
Jan 19 19:44:00 <hostname> kernel: [ 1507.052782]  [<ffffffff8109b8a0>] ? kthread_park+0x60/0x60
Jan 19 19:44:00 <hostname> kernel: [ 1507.052786]  [<ffffffff817de34f>] ret_from_fork+0x3f/0x70
Jan 19 19:44:00 <hostname> kernel: [ 1507.052788]  [<ffffffff8109b8a0>] ? kthread_park+0x60/0x60

Thanks,
Kaiwen

On Wed, Jan 25, 2017 at 11:50:25AM -0800, Cong Wang wrote:
> Hello,
> 
> On Mon, Jan 23, 2017 at 9:17 PM, Kaiwen Xu <kevin@kevxu.net> wrote:
> > Hi netdev folks,
> >
> > I am currently experiencing an issue related with the loopback during
> > network devices shutdown inside a network namespace, which mainfested as
> >
> >     unregister_netdevice: waiting for lo to become free. Usage count = 1
> >
> > showing up every 10 seconds or so in the kernel log. It eventually
> > causes a deadlock on new network namespace creation.
> 
> It is at least the 3rd time I saw this bug report. ;)
> 
> >
> > When I was trying to debug the issue, I tested from latest kernel 4.10-rc
> > back to 3.19, which all can be reproduced on. I also tried to disable
> > IPv6, which doesn't help either.
> >
> > So I tried to patch the kernel with following change to add addtional
> > logging message for dev_put() and dev_hold().
> >
> >     https://lkml.org/lkml/2008/7/20/5
> >
> > Here are all the dev_put/hold() calls for the loopback device inside a
> > namespace from creation to shutdown, when the issue occurs.
> 
> Excellent debugging!
> 
> From your debugging output, the dst_ifdown() looks suspicious to me,
> it seems to be the reason why we miss one dev_put().
> 
> 
> > Could you please give me some pointers why this issue could occur? I can
> > also provide addtional information if needed.
> >
> 
> Do you mind to try the attached patch (compile only)? Try it with your
> debugging printk's in case it doesn't fix this bug, but it should make some
> difference at least.
> 
> Thanks!

> diff --git a/net/core/dst.c b/net/core/dst.c
> index b5cbbe0..99184ba 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -441,8 +441,12 @@ static void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
>  		dst->input = dst_discard;
>  		dst->output = dst_discard_out;
>  	} else {
> -		dst->dev = dev_net(dst->dev)->loopback_dev;
> -		dev_hold(dst->dev);
> +		if (dst->dev != dev_net(dst->dev)->loopback_dev) {
> +			dst->dev = dev_net(dst->dev)->loopback_dev;
> +			dev_hold(dst->dev);
> +		} else {
> +			dst->dev = NULL;
> +		}
>  		dev_put(dev);
>  	}
>  }
