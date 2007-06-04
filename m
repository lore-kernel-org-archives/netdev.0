From: Ingo Molnar <mingo@elte.hu>
Subject: Re: iperf: performance regression (was b44 driver problem?)
Date: Mon, 4 Jun 2007 21:32:06 +0200
Message-ID: <20070604193206.GA13271@elte.hu>
References: <20070525172431.60affaca@freepuppy> <200705281944.05030.maxi@daemonizer.de> <1180380230.3657.3.camel@chaos> <200706031826.06891.maxi@daemonizer.de> <1180939188.4404.5.camel@chaos> <20070604090918.42386fbb@freepuppy> <1180974958.4404.24.camel@chaos> <20070604095924.651d91c8@freepuppy> <1180978368.4404.29.camel@chaos> <20070604105158.31ede1f5@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ulrich Drepper <drepper@gmail.com>,
	Maximilian Engelhardt <maxi@daemonizer.de>,
	Michael Buesch <mb@bu3sch.de>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:60633 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762440AbXFDTcf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 15:32:35 -0400
Content-Disposition: inline
In-Reply-To: <20070604105158.31ede1f5@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> Yes, the following patch makes iperf work better than ever. But are 
> other broken applications going to have same problem. Sounds like the 
> old "who runs first" fork() problems.

this is the first such app and really, and even for this app: i've been 
frequently running iperf on -rt kernels for _years_ and never noticed 
how buggy its 'locking' code was, and that it would under some 
circumstances use up the whole CPU on high-res timers.

If this were a widespread problem then the right solution would be to 
preserve the old behavior. The child-runs-first thing was an unspecified 
detail and many apps grew to depend on how the kernel did it - and when 
we changed it all hell broke lose. Even today, when i switch off 
child-runs-first, Gnome would not start up because some of its startup 
threads are racy and hang :-/

I googled for usleep(0) quickly (on google.com/codesearch and on 
google.com) and it didnt seem to suggest that the problem is widespread. 
(3 hits on the code-search site, all were false positives.)

so ... if this situation were even just a little bit more serious i'd 
argue for working this around and implementing some API quirk. But right 
now i'm leaning towards just saying that the iperf fix exists and fixes 
the problem, and that we already have kernels out with the new behavior. 
Maybe we should add a once-per-boot printk to flesh out any other apps? 
I'd be surprised if there was more than iperf.

	Ingo
