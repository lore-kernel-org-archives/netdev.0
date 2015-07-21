From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] inet: Always increment refcount in
 inet_twsk_schedule
Date: Tue, 21 Jul 2015 09:10:10 +0200
Message-ID: <1437462610.1026.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <d6222bf87f44ca3adf3988202bd31a3c.squirrel@www.codeaurora.org>
	 <1437295872.1026.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <99d6ce13c5da5ea403b3df747d770d54.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:36561 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbbGUHKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 03:10:15 -0400
Received: by wgbcc4 with SMTP id cc4so54938815wgb.3
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 00:10:13 -0700 (PDT)
In-Reply-To: <99d6ce13c5da5ea403b3df747d770d54.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-07-20 at 19:14 +0000, subashab@codeaurora.org wrote:
> >> //Initialize time wait socket and setup timer
> >> inet_twsk_alloc() tw_refcnt = 0
> >> __inet_twsk_hashdance() tw_refcnt = 3
> >> inet_twsk_schedule() tw_refcnt = 4
> >> inet_twsk_put() tw_refcnt = 3
> >>
> >> //Receive packet 1 in timewait state
> >> tcp_timewait_state_process() -> inet_twsk_schedule tw_refcnt = 3 (no
> >> change)
> >
> > This is obviously wrong.
> >
> > If a timewait socket is found, do we increment its refcnt before
> > proceeding.
> We do not increment refcount currently when we find a timewait socket.

Actually we do increment refcnt, for every socket found in ehash.

Carefully read again __inet_lookup_established()

This code is generic for ESTABLISH and TIME-WAIT sockets

If you found a code that performed the lookup without taking the refcnt,
please point me at it, this would be a serious bug.

> 
> > I've received some private mails about tw issues, that turned to be
> > caused by buggy drivers or buggy arch specific code.
> >
> > Are you crashed observed on x86 ?
> >
> This is observed on ARM devices. In the current debug, all time wait
> socket refcount changes were happening in TCP stack only and there was no
> platform / driver code involved.
> 
> According to my understanding, we would need to increment the time wait
> socket refcount first before proceeding with any subsequent operations.
> However, I request your expert opinion on this.

Is it some Android kernel ?

Android had private modules that needed an update in 3.18
