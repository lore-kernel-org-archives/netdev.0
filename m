From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Linux 3.0 release
Date: Fri, 22 Jul 2011 15:09:56 -0700
Message-ID: <20110722150956.5b341488@nehalam.ftrdhcpuser.net>
References: <CA+55aFxakA2U+oMJ1T7awTYa+p6xp9N0aCbfrUqgkF7BJ8gnQw@mail.gmail.com>
	<4E29CB5B.4040408@unsolicited.net>
	<CA+55aFy1FnVGH4C_0T8fXwZPUdz5-SCczMwy1K8kydLwTx89RQ@mail.gmail.com>
	<4E29D326.7070403@candelatech.com>
	<20110722133220.0baf2199@nehalam.ftrdhcpuser.net>
	<20110722212629.GA10833@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David <david@unsolicited.net>, Tejun Heo <tj@kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110722212629.GA10833@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Jul 2011 23:26:29 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@vyatta.com> :
> > This a regression which probably began with
> > 
> > commit e22bee782b3b00bd4534ae9b1c5fb2e8e6573c5c
> > Author: Tejun Heo <tj@kernel.org>
> > Date:   Tue Jun 29 10:07:14 2010 +0200
> > 
> >     workqueue: implement concurrency managed dynamic worker pool
> > 
> > Before that it was perfectly legal for link watch code to
> > call schedule_delayed_work from IRQ. This should be allowable;
> > the code to manage the worker pool should handle it.
> 
> I beg to differ: see Ben's first report
> (http://lists.openwall.net/netdev/2011/05/04/183).
>                                        ^^
> 
> One of the code path in the netif_carrier code leads it to try and disable
> a late workqueue to reenable it immediately (mod_workqueue anyone ?):
> netif_carrier_on
> -> linkwatch_fire_event
>    -> linkwatch_schedule_work
>       -> cancel_delayed_work
>          -> del_timer_sync
> 
> The del_timer_sync has been here for ages. Afaiks it is not a new pool code
> nor a schedule_delayed_work only problem.
> 

That path can be fixed by calling _cancel_delayed_work() instead.
