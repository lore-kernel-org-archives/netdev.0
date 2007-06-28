From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bugme-new] [Bug 8668] New: HTB Deadlock
Date: Thu, 28 Jun 2007 09:52:31 +0200
Message-ID: <20070628075231.GB1618@ff.dom.local>
References: <20070627114521.GA3762@ff.dom.local> <46824D88.1090300@trash.net> <20070627121013.GB3762@ff.dom.local> <468279FC.3070502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:43382 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759486AbXF1HoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 03:44:19 -0400
Content-Disposition: inline
In-Reply-To: <468279FC.3070502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 27, 2007 at 04:53:48PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> >On Wed, Jun 27, 2007 at 01:44:08PM +0200, Patrick McHardy wrote:
> >  
> >>>BTW, maybe I look at this too short, but is this del_timer()
> >>>in gen_kill_estimator() enough? I cannot see nothing against
> >>>a timer just running and doing mod_timer() again...
> >>>      
> >>Yes, but nothing bad can happen, the timer will find an empty
> >>list and do nothing. It would make more sense to check for
> >>an empty list before restarting the timer though.

Maybe this time I've looked at this too much, but actually
I think some "badness" is possible: if I'm not missing something
such timer would rearm constantly, so, there could be some
collision when gen_new_estimator() tries to add new timer.

> >>
> >>
> >>Could you send a patch for that?
> >>
> >>    
> >
> >Probably I could, but it's your idea!
> >
> >I look at this just now, and maybe it's enough for asking,
> >but definitely not enough for patch. I'll try to check this
> >more in the evening, so I could send something tomorrow.
> >
> >So if it's not only about kindness, feel free to do it
> >sooner and I've no doubts  - better.
> 
> I can take care of it, no problem.
 
Thanks. I've some technical limitations, so such small changes
take much time if there is a need to get the most up-to-date
kernel and do at least "compile testing". I'm not much about
credits, so I'd prefer to do such things only if it's not very
urgent and could save some signifying amount of your time too.

BTW #2, I hope it's about some new policy, but I cannot see
any #ifdef CONFIG_NET_ESTIMATOR in this sch_htb patch.

Jarek P.


