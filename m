From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: Tree for September 3
Date: Thu, 4 Sep 2008 16:17:46 -0700
Message-ID: <20080904161746.dc4800a4.akpm@linux-foundation.org>
References: <20080903191619.6b6b230e.sfr@canb.auug.org.au>
	<20080903214634.ea17ff53.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809032201510.3378@nehalem.linux-foundation.org>
	<20080903223318.84b6ce8b.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040045190.3378@nehalem.linux-foundation.org>
	<20080904012544.cabed847.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040143350.3452@nehalem.linux-foundation.org>
	<20080904015701.5959623a.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040203510.3452@nehalem.linux-foundation.org>
	<20080904104554.32ffebea.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809041058140.3400@nehalem.linux-foundation.org>
	<20080904113408.d47c65f6.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809050041520.3243@apollo.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	yhlu.kernel@gmail.com, ink@jurassic.park.msu.ru,
	jbarnes@virtuousgeek.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, ebiederm@xmission.com,
	dwmw2@infradead.org, sam@ravnborg.org, johnstul@us.ibm.com
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50371 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754801AbYIDXSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 19:18:36 -0400
In-Reply-To: <alpine.LFD.1.10.0809050041520.3243@apollo.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Sep 2008 00:45:33 +0200 (CEST)
Thomas Gleixner <tglx@linutronix.de> wrote:

> On Thu, 4 Sep 2008, Andrew Morton wrote:
> > 
> > and oh dear, the clockevents code just oopsed.
> 
> Sigh.
>  
> > BUG: unable to handle kernel NULL pointer dereference at 00000040
> > IP: [<c0126e7f>] get_next_timer_interrupt+0xe9/0x1ab
> 
> Cute, NULL pointer in the timer check code. Can you please addr2line
> the exact code line or upload the vmlinux somewhere ?
> 

erm, I might have lost that binary, and it only happened the once.  It
happened shortly after the machine had fully booted, during
establishment of the first sshd session.

It nuked the machine really well, too.  I had to pull the battery to
get it back.

fwiw:


(gdb) l *0xc0126e7f
0xc0126e7f is in get_next_timer_interrupt (kernel/timer.c:863).
warning: Source file is more recent than executable.
858             for (array = 0; array < 4; array++) {
859                     struct tvec *varp = varray[array];
860     
861                     index = slot = timer_jiffies & TVN_MASK;
862                     do {
863                             list_for_each_entry(nte, varp->vec + slot, entry) {
864                                     found = 1;
865                                     if (time_before(nte->expires, expires))
866                                             expires = nte->expires;
867                             }

which looks reasonable.
