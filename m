From: Yue Cao <ycao009@ucr.edu>
Subject: Re: [PATCH v2 net] tcp: make challenge acks less predictable
Date: Sun, 10 Jul 2016 11:28:10 -0700
Message-ID: <CAPzkZjwS9Kabtg0g==QrTUmyR0PUfy8C76XueanNivYSDLZZGg@mail.gmail.com>
References: <1467995586.30694.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAPzkZjz1R_T8q75LXLBc91j7YrngxdPc-o2Hpz+4YYyoWLantA@mail.gmail.com>
 <1468052160.30694.51.camel@edumazet-glaptop3.roam.corp.google.com>
 <1468137842.30694.58.camel@edumazet-glaptop3.roam.corp.google.com> <CADVnQym7nL8AekOFYFH3pcnLerHBAC4BrYv5hY6Z5HN7kGkVkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.ucr.edu ([138.23.62.3]:6135 "EHLO mx2.ucr.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755819AbcGJS2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2016 14:28:13 -0400
Received: by mail-oi0-f72.google.com with SMTP id w207so83396579oiw.1
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 11:28:12 -0700 (PDT)
In-Reply-To: <CADVnQym7nL8AekOFYFH3pcnLerHBAC4BrYv5hY6Z5HN7kGkVkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This second patch does make our attack much harder but it's still
possible to do such off-path attack with enough network bandwidth.
Here is our modified attack for this second patch.

Modified Attack:
Main idea of our attack is to send multiple same spoofed packets in 1
second so attacker can confirm if it's a right guess or wrong guess.
In more detail, attacker sends more than 1000 (e.g. 1500) spoofed
packets for a same guessed value at beginning. After that, attacker
sends 1500 packets during the same second to determine whether
previous guess is right or wrong, by using following rules:
If attacker receives less than 500 Challenge ACKs, it's a right guess.
For a example, if 1500 spoofed packets are sent with a correct
value(right guess), all Challenge ACKs will be sent to victim client
in that second and attacker receives nothing. Otherwise, it's a wrong
guess.

Since this global rate limit always leaks some information as a
side-channel, we are wondering if eliminating it completely would be a
good idea. In fact, according to our latest test, FreeBSD and Windows
do not have any such rate limit implemented. Looking forward to your
replies.

Best,
Yue

On Sun, Jul 10, 2016 at 5:55 AM, Neal Cardwell <ncardwell@google.com> wrote:
>
> On Sun, Jul 10, 2016 at 4:04 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Yue Cao claims that current host rate limiting of challenge ACKS
> > (RFC 5961) could leak enough information to allow a patient attacker
> > to hijack TCP sessions. He will soon provide details in an academic
> > paper.
> >
> > This patch increases the default limit from 100 to 1000, and adds
> > some randomization so that the attacker can no longer hijack
> > sessions without spending a considerable amount of probes.
> >
> > Based on initial analysis and patch from Linus.
> >
> > Note that we also have per socket rate limiting, so it is tempting
> > to remove the host limit in the future.
> >
> > v2: randomize the count of challenge acks per second, not the period.
> >
> > Fixes: 282f23c6ee34 ("tcp: implement RFC 5961 3.2")
> > Reported-by: Yue Cao <ycao009@ucr.edu>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> > Cc: Yuchung Cheng <ycheng@google.com>
> > Cc: Neal Cardwell <ncardwell@google.com>
>
> Acked-by: Neal Cardwell <ncardwell@google.com>
>
> Thanks, Eric!
>
> neal
