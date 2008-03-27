From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 10326] New: inconsistent lock state in
	net_rx_action
Date: Thu, 27 Mar 2008 11:07:00 +0100
Message-ID: <20080327100700.GA2845@ami.dom.local>
References: <bug-10326-10286@http.bugzilla.kernel.org/> <20080325134320.21525479.akpm@linux-foundation.org> <47EAD8A5.3070806@gmail.com> <20080326171403.ad186037.akpm@linux-foundation.org> <20080327085542.GA2778@ami.dom.local> <20080327021812.601776b8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	marcus@better.se,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	LKML <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@elte.hu>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:55588 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbYC0KCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 06:02:25 -0400
Received: by ug-out-1314.google.com with SMTP id z38so299145ugc.16
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 03:02:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080327021812.601776b8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2008 at 02:18:12AM -0700, Andrew Morton wrote:
...
> Anyway, the accusation is that lockdep is busted, in that it doesn't realise that
> local_irq_disable() blocks softirqs.

Usually lockdep gets this right, so I've some doubts too. But here
it's not only about softirqs; this:

> >> Mar 25 19:48:46 better kernel:  #1:  (target_list_lock){--..}, at: [<c0399c0d>]

means lockdep saw hardirqs enabled while acquiring/holding this lock.

Jarek P.
