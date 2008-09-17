From: "Michael Kerrisk" <mtk.manpages@googlemail.com>
Subject: Re: sys_paccept: disable paccept() until API design is resolved
Date: Wed, 17 Sep 2008 02:24:32 +0200
Message-ID: <cfd18e0f0809161724w646b1e21s466afe74579f12e0@mail.gmail.com>
References: <48CFA10D.2010106@gmail.com> <48D03E85.9030808@redhat.com>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>,
	"Davide Libenzi" <davidel@xmailserver.org>,
	"Alan Cox" <alan@redhat.com>, "Jakub Jelinek" <jakub@redhat.com>,
	lkml <linux-kernel@vger.kernel.org>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	"Roland McGrath" <roland@redhat.com>,
	"Oleg Nesterov" <oleg@tv-sign.ru>,
	"Christoph Hellwig" <hch@lst.de>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
To: "Ulrich Drepper" <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:34006 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259AbYIQAYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 20:24:33 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2920467rvb.1
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 17:24:32 -0700 (PDT)
In-Reply-To: <48D03E85.9030808@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2008 at 1:17 AM, Ulrich Drepper <drepper@redhat.com> wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> Michael Kerrisk wrote:
>> The patch below disables the new sys_paccept() for now.  Please
>> apply for 2.6.27-rc, so that we do not release this API into
>> the wild before a conclusion has been reached about its design.
>
> There is no reason for that.
>
>
>> The reasons for disabling paccept() are as follows:
>>
>> * The API is more complex than needed.  There is AFAICS no demonstrated
>>   use case that the sigset argument of this syscall serves that
>>   couldn't equally be served by the use of pselect/ppoll/epoll_pwait +
>
> It would unnecessarily require programs to be changed.

What is "it"?  What "would unnecessarily require programs to be changed"?

> I've explained
> that programs cannot efficiently use accept() and poll() when multiple
> threads are involved.  This means in these situations you'll find a
> single thread handling only the accept() calls.

I'm assuming that you mean this text from another thread:

[[
> accept, like select/poll, is used often as a function to dealy
> operation.  Unlike read, recv, etc, which are handled using O_NONBLOCK
> and select/poll.  pselect/ppoll do not really have a sigset parameter
> to handle signals in general.  You use it to enable special handling
> in case of blocking.  Example: if you want to implement userlevel
> context switching, you dedicate a signal to wake up any blocked
> thread.  Since accept falls more into the same category than poll,
> this means the sigset parameter is justified.  In theory we could add
> it to all functions but there is no reason to do this without any
> other reason to change the interface.
]]

I find this very difficult to understand -- what makes it difficult is
the wording of the explanation.  Could you please take some time to
(much) more clearly explain the above, and especially to very clearly
explain why paccept() serves needs that can't be dealt with by
pseelect/ppoll/epoll_pwait + accept().

>> * The use of a sigset argument is not consistent with other I/O APIs
>>   that can block on a single file descriptor (e.g., read(), recv(),
>>   connect()).
>
> This is because none of the other interfaces had (so far) be revised.
> With this flawed argumentation you'd prevent any program ever to be made.
>
>
>> * The behavior of paccept() when interrupted by a signal is IMO
>>   strange:
>
> You use your own opinion as the deciding factor?

I already clearly stated it was my opinion, and pointed out that
Roland had a diffferent opinion.  Really, what is your point?

> The behavior differs
> from other uses but is consistent with the accept() behavior.
>
>> I believe that instead, a simpler API, consistent with Ulrich's
>> other recent additions, is preferable:
>>
>> accept4(int fd, struct sockaddr *sa, socklen_t *salen, ind flags);
>
> The signal set wasn't actually my idea.  See:
>
> http://marc.info/?l=linux-kernel&m=120909788728078&w=2

[CC=+ Evgeniy Polyakov <johnpol@2ka.mipt.ru>]

But, what are you trying to say in pointing out that this wasn't your idea?

>> At this point, I am hoping we either will get a counter-argument
>> from Ulrich about why we really do need paccept()'s sigset argument,
>> or that he will resubmit the original accept4() patch.
>
> I have explained the need already. you just chose to ignore it.

No.  You still have given no clear explanation.  Please give one.

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
man-pages online: http://www.kernel.org/doc/man-pages/online_pages.html
Found a bug? http://www.kernel.org/doc/man-pages/reporting_bugs.html
