From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Fri, 26 Jun 2009 15:46:43 +0200
Message-ID: <20090626134643.GA3845@redhat.com>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com> <20090625122416.GA23613@redhat.com> <alpine.DEB.1.10.0906251827510.9517@makko.or.mcafeemobile.com> <4A442B65.8040701@gmail.com> <alpine.DEB.1.10.0906251858520.9517@makko.or.mcafeemobile.com> <4A443033.8060401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Davide Libenzi <davidel@xmailserver.org>,
	Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	Tejun Heo <htejun@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57424 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757594AbZFZRBV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2009 13:01:21 -0400
Content-Disposition: inline
In-Reply-To: <4A443033.8060401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/26, Eric Dumazet wrote:
>
> Davide Libenzi a =E9crit :
> >
> > Do you think of it as good design adding an MB on a subsystem, beca=
use of
> > the special locking logic of another one?
> > The (eventual) slowdown, IMO can be argued sideways, by saying that
> > non-socket users will pay the price for their polls.
>
> I wont argue with you David, just try to correct bugs.

I must admit, I agree with David.

> fs/ext4/ioctl.c line 182
>
> 	set_current_state(TASK_INTERRUPTIBLE);
> 	add_wait_queue(&EXT4_SB(sb)->ro_wait_queue, &wait);
> 	if (timer_pending(&EXT4_SB(sb)->turn_ro_timer)) {
> 		schedule();
>
> Another example of missing barrier after add_wait_queue()

Assuming that ->turn_ro_timer does wake_up(->ro_wait_queue) everything
is OK, we do not need a barrier.

Oleg.

