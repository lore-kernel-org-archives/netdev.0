From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bnx2x: Fix netpoll interoperability
Date: Tue, 14 Apr 2015 11:24:57 -0700
Message-ID: <1429035897.7346.49.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429018513-9553-1-git-send-email-Yuval.Mintz@qlogic.com>
	 ,<1429023140.7346.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF5830@AVMB1.qlogic.org>
	 ,<1429033912.7346.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF58CE@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, "bind@enas.net" <bind@enas.net>,
	"peter@hurleysoftware.com" <peter@hurleysoftware.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36754 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356AbbDNSY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 14:24:59 -0400
Received: by igblo3 with SMTP id lo3so81977096igb.1
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 11:24:58 -0700 (PDT)
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63CF58CE@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-14 at 18:11 +0000, Yuval Mintz wrote:
> > I believe the original busypoll yield concern was forgotten or reversed.
> 
> > If you have many busypoll users, they might get the 'lock', and the poor
> > cpu that received the hardware interrupt and raised RX softirq for this
> > RX queue will spin forever [1]
> 
> > busypoll users should backoff and not attempt to grab a lock (especially
> > if this lock is not a ticket lock anymore) if the softirq handler is
> > desperately trying to make progress.
> 
> > [1]
> > sofirq handler
> 
> >   while (1) {
> >       if (!bnx2x_fp_lock_napi())
> >                continue;
> 
> bnx2x returns the budget, it doesn't loop in the poll function.

returning budget literally asks to call again asap.

> [I don't have the napi_poll logic in mind, but I do hope it doesn't iterate
> repeatedly but rather only on next re-schedule]


I can tell you it loops. Look again at the code.

To break the loop, you have to call napi_complete()



> >        }
> >   }
> 
> > I can provide an alternative patch if you like.
> 
> If you're willing to make the effort, sure.

Yes, will do that shortly.
