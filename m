From: Andy Walls <awalls@md.metrocast.net>
Subject: Re: [PATCH 00/50] USB: cleanup spin_lock in URB->complete()
Date: Sun, 14 Jul 2013 09:17:24 -0400
Message-ID: <1373807844.4998.10.camel@palomino.walls.org>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-kernel@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proofpoint-cluster.metrocast.net ([65.175.128.136]:57395 "EHLO
	proofpoint-cluster.metrocast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752246Ab3GNN0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jul 2013 09:26:44 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-11 at 17:05 +0800, Ming Lei wrote:
> Hi,
> 
> As we are going to run URB->complete() in tasklet context[1][2],

Hi,

Please pardon my naivete, but why was it decided to use tasklets to
defer work, as opposed to some other deferred work mechanism?

It seems to me that getting rid of tasklets has been an objective for
years:

http://lwn.net/Articles/239633/
http://lwn.net/Articles/520076/
http://lwn.net/Articles/240054/


Regards,
Andy

>  and
> hard interrupt may be enabled when running URB completion handler[3],
> so we might need to disable interrupt when acquiring one lock in
> the completion handler for the below reasons:
> 
> - URB->complete() holds a subsystem wide lock which may be acquired
> in another hard irq context, and the subsystem wide lock is acquired
> by spin_lock()/read_lock()/write_lock() in complete()
> 
> - URB->complete() holds a private lock with spin_lock()/read_lock()/write_lock()
> but driver may export APIs to make other drivers acquire the same private
> lock in its interrupt handler.
> 
> For the sake of safety and making the change simple, this patch set
> converts all spin_lock()/read_lock()/write_lock() in completion handler
> path into their irqsave version mechanically.
> 
> But if you are sure the above two cases do not happen in your driver,
> please let me know and I can drop the unnecessary change.
> 
> Also if you find some conversions are missed, also please let me know so
> that I can add it in the next round.
> 
> 
> [1], http://marc.info/?l=linux-usb&m=137286322526312&w=2
> [2], http://marc.info/?l=linux-usb&m=137286326726326&w=2
> [3], http://marc.info/?l=linux-usb&m=137286330626363&w=2
> 
[snip]
> 
> 
> Thanks,
> --
> Ming Lei
