From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/2] genl: Fix genl dumpit() locking.
Date: Thu, 22 Aug 2013 13:31:25 -0700
Message-ID: <CALnjE+osiw-uPdf8JEX=jG+zwaoypoSQ_A+N-WiVUkxxT63y+g@mail.gmail.com>
References: <1377143882-20717-1-git-send-email-pshelar@nicira.com>
	<1377156980.14110.16.camel@jlt4.sipsolutions.net>
	<CALnjE+qgZ_UZ4GdiZ4UCzfTLn-OveoHtE28uQZokz2kPD4srXQ@mail.gmail.com>
	<1377193906.14110.27.camel@jlt4.sipsolutions.net>
	<CALnjE+rEOMmyFQ0Nx3-O-Cvu8yePVBg7x8vgpGUOAAnYv3KG4Q@mail.gmail.com>
	<1377195534.14110.29.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:43953 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753397Ab3HVUbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 16:31:43 -0400
Received: by mail-qe0-f52.google.com with SMTP id a11so1413853qen.39
        for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 13:31:25 -0700 (PDT)
In-Reply-To: <1377195534.14110.29.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 22, 2013 at 11:18 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Thu, 2013-08-22 at 11:10 -0700, Pravin Shelar wrote:
>
>> > By the way - why? This just means that netlink will allocate another
>> > lock to lock it all, so it's not a very useful change?
>> >
>> This replaces global genl-lock with per-socket lock which allows
>> parallel operation in parallel-genl-families and they are not blocked
>> due to other unrelated genl-family operations.
>
> I don't think so? It replaces the genl lock as cb_mutex with a per
> *kernel* socket lock, so really just one per network namespace. That's
> not much of an improvement really.
>

You are thinking abt genl-sock -> nlk -> cb_lock which is not used in
genl-dump locking if cb_lock is NULL while creating nl socket.
