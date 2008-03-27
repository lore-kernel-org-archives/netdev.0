From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 10326] New: inconsistent lock state in
	net_rx_action
Date: Thu, 27 Mar 2008 09:55:42 +0100
Message-ID: <20080327085542.GA2778@ami.dom.local>
References: <bug-10326-10286@http.bugzilla.kernel.org/> <20080325134320.21525479.akpm@linux-foundation.org> <47EAD8A5.3070806@gmail.com> <20080326171403.ad186037.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	marcus@better.se,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:13965 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754830AbYC0Ivi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 04:51:38 -0400
Received: by wr-out-0506.google.com with SMTP id c48so3214386wra.1
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 01:51:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080326171403.ad186037.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2008 at 05:14:03PM -0700, Andrew Morton wrote:
...
> > >> http://bugzilla.kernel.org/show_bug.cgi?id=10326
...
> No, it's not an irq_disable() thing, directly.
> 
> What lockdep is saying is that sky2_poll() is taking napi->poll_lock for
> writing with softirqs enabled, but net_rx_action() takes the same lock from
> within softirq context.
> 
> If sky2_poll() always takes napi->poll_lock under local_irq_disable() then
> that would be a lockdep bug.

sky2_poll() doesn't take napi->poll_lock; this lock is taken by
netpoll_poll() before calling sky2_poll(). And before this hardirqs
are disabled in write_msg(). So, theoretically lockdep could be right
if sky2_poll() would enable irqs after this. (If it were done in
netpoll - lockdep should warn before or after sky2_poll() call.)
But I really can't see any such possibility in sky2_poll().

Regards,
Jarek P.
