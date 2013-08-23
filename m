From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/2] genl: Fix genl dumpit() locking.
Date: Fri, 23 Aug 2013 13:52:57 -0700
Message-ID: <CALnjE+qn8THcPABZojWoE3OW2Y2TKZGSjB24ZWLC5AGM5yKm9w@mail.gmail.com>
References: <1377143882-20717-1-git-send-email-pshelar@nicira.com>
	<1377156980.14110.16.camel@jlt4.sipsolutions.net>
	<CALnjE+qgZ_UZ4GdiZ4UCzfTLn-OveoHtE28uQZokz2kPD4srXQ@mail.gmail.com>
	<1377193906.14110.27.camel@jlt4.sipsolutions.net>
	<CALnjE+rEOMmyFQ0Nx3-O-Cvu8yePVBg7x8vgpGUOAAnYv3KG4Q@mail.gmail.com>
	<1377195534.14110.29.camel@jlt4.sipsolutions.net>
	<CALnjE+osiw-uPdf8JEX=jG+zwaoypoSQ_A+N-WiVUkxxT63y+g@mail.gmail.com>
	<1377242982.14021.8.camel@jlt4.sipsolutions.net>
	<1377251485.14021.17.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:52894 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756017Ab3HWUxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 16:53:07 -0400
Received: by mail-qc0-f176.google.com with SMTP id u12so600292qcx.7
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 13:52:57 -0700 (PDT)
In-Reply-To: <1377251485.14021.17.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 23, 2013 at 2:51 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Fri, 2013-08-23 at 09:29 +0200, Johannes Berg wrote:
>
>> > You are thinking abt genl-sock -> nlk -> cb_lock which is not used in
>> > genl-dump locking if cb_lock is NULL while creating nl socket.
>>
>> You're right, this is also done for each userland socket, so each socket
>> now gets its own cb_mutex. This would help genl families with
>> parallel_ops.
>
> I'm still missing something. Kernel 3.4 had cb_mutex assign to the
> genl_mutex, but we saw the original crash there, apparently dumpit
> *wasn't* (always) locked with it?
>
Can you point me to original crash on 3.4?

Thanks.
