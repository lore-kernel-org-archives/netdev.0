From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: thousands of classes, e1000 TX unit hang
Date: Tue, 5 Aug 2008 18:41:03 +0200
Message-ID: <20080805164103.GB2526@ami.dom.local>
References: <20080805110453.GA6541@ff.dom.local> <200808051413.58795.denys@visp.net.lb> <20080805122340.GB6541@ff.dom.local> <200808051602.08047.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:26456 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758259AbYHEQkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 12:40:45 -0400
Received: by ug-out-1314.google.com with SMTP id h2so87248ugf.16
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 09:40:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808051602.08047.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 04:02:05PM +0300, Denys Fedoryshchenko wrote:
> >
> > Very interesting. Anyway tbf doesn't use gen estimators, so you could
> > test if it makes big difference for you.
> I can prepare provide details with graphs to private email and reasons why i 
> do that. With TBF i think i cannot use flow classifier, if i am not wrong, i 
> must attach classful disciplines. I tried to attach just pfifo - and i fail.

If such config works for you then why bother? I've some doubts, but
not enough to study some graphics ;)

> > Actually, gen_kill_estimator was rewritten already, but for some
> > reason it wasn't merged. Maybe there isn't so much users with such a
> > number of classes or they don't delete them, anyway this subject isn't
> > reported often to the list (I remember once). Some workaround could be
> > probably deleting individual classes (and filters) to give away a lock
> > and soft interrupts for a while), before deleting the root, but I
> > didn't test this. BTW, you are using quite long queues (3000), so there
> > would be interesting to make them less and check if doesn't add to the
> > problem (with retransmits).
> >
> > Jarek P.
> Well i am first :-) Many people prefer buy Cisco and put static shaper on 
> their NAS for customer. With iproute2 it is possible to make MUCH better 
> feeling of using maximum bandwidth, and at same time not feeling it is 
> reached maximum. Since in some applications i have much more than amount of 
> flows SFQ can provide (and especially inefficient hashing it uses), i need 
> flow classifier and a lot of classes.
> 
> Many users on my experience dont know much about kernel maillist, and they 
> didn't got used to report about problems. Now i am collecting some feedbacks 
> from my friends and trying to reproduce and report here.

Alas you are the second:
http://www.mail-archive.com/netdev@vger.kernel.org/msg60101.html 

If you think this gen_kill_estimator() fix will solve your problems
you can try to upgrade this patch and resend as yours or ours, it's
not copyrighted. Of course, no guarantee it'll be accepted this time.

Jarek P.
