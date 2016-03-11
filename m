From: Tejun Heo <tj@kernel.org>
Subject: Re: net/bluetooth: workqueue destruction WARNING in
 hci_unregister_dev
Date: Fri, 11 Mar 2016 12:12:05 -0500
Message-ID: <20160311171205.GB24046@htj.duckdns.org>
References: <CACT4Y+ax7zMOxe+kd4tw5Xdbvt=qPdBhXGO0j7qJwdn5tsfNNg@mail.gmail.com>
 <56C5CE85.6090808@suse.cz>
 <CACT4Y+bVXfY=wBZ+08rq16tHFw9s3YDrE_LCS=to-GF70AffRQ@mail.gmail.com>
 <20160218174427.GG13177@mtj.duckdns.org>
 <56C6EC62.8080107@suse.cz>
 <56C70618.3010902@suse.cz>
 <20160302154507.GC4282@mtj.duckdns.org>
 <56D7FFE1.90900@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Takashi Iwai <tiwai@suse.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:36425 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932643AbcCKRMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 12:12:09 -0500
Content-Disposition: inline
In-Reply-To: <56D7FFE1.90900@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Sorry about the delay.

On Thu, Mar 03, 2016 at 10:12:01AM +0100, Jiri Slaby wrote:
> On 03/02/2016, 04:45 PM, Tejun Heo wrote:
> > On Fri, Feb 19, 2016 at 01:10:00PM +0100, Jiri Slaby wrote:
> >>> 1. didn't help, the problem persists. So I haven't applied the patch from 2.
> >>
> >> FWIW I dumped more info about the wq:
> >> wq->name='hci0' pwq=ffff8800390d7600 wq->dfl_pwq=ffff8800390d5200
> >> pwq->refcnt=2 pwq->nr_active=0 delayed_works: <nothing>
> > 
> > Can you please print out the same info for all pwq's during shutdown?
> > It looks like we're leaking pwq refcnt but I can't spot a place where
> > that could happen on an empty pwq.
> 
> I have not done that yet, but today, I see:
> destroy_workqueue: name='req_hci0' pwq=ffff88002f590300
> wq->dfl_pwq=ffff88002f591e00 pwq->refcnt=2 pwq->nr_active=0 delayed_works:
>    pwq 12: cpus=0-1 node=0 flags=0x4 nice=-20 active=0/1
>      in-flight: 18568:wq_barrier_func

So, this means that there's flush_work() racing against workqueue
destruction, which can't be safe. :(

Thanks.

-- 
tejun
