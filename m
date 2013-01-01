From: "Junchang(Jason) Wang" <junchang.wang@yale.edu>
Subject: Re: [PATCH] poll: prevent missed events if _qproc is NULL
Date: Tue, 1 Jan 2013 18:21:03 -0500
Message-ID: <CAErQho4EdoTD9+KhS3bRN9QFxfPRuTO-oh=z1J7tEBQqp4nTMA@mail.gmail.com>
References: <20121228014503.GA5017@dcvr.yhbt.net>
	<1356960060-1263-1-git-send-email-normalperson@yhbt.net>
	<1357065750.21409.12527.camel@edumazet-glaptop>
	<20130101210033.GA13255@dcvr.yhbt.net>
	<20130101211728.GA13380@dcvr.yhbt.net>
	<CA+55aFwP3Tvmfh23KDDXhB3k=RS8pNhqasw5vuBUHw4TxrakOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Hans Verkuil <hans.verkuil@cisco.com>,
	Jiri Olsa <jolsa@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Hans de Goede <hdegoede@redhat.com>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andreas Voellmy <andreas.voellmy@yale.edu>,
	Network Development <netdev@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Wong <normalperson@yhbt.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwP3Tvmfh23KDDXhB3k=RS8pNhqasw5vuBUHw4TxrakOQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

The alternate patch from Eric works well too. Even though I didn't see
a performance boost compared with the old version, this one is clearer
to me. Thanks your guys.


Cheers!

--Jason


On Tue, Jan 1, 2013 at 5:53 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Jan 1, 2013 at 1:17 PM, Eric Wong <normalperson@yhbt.net> wrote:
>>>
>>> An alternate version (limited to epoll) would be:
>>>
>>> diff --git a/fs/eventpoll.c b/fs/eventpoll.c
>>> index cd96649..ca5f3d0 100644
>>> --- a/fs/eventpoll.c
>>> +++ b/fs/eventpoll.c
>>> @@ -1299,6 +1299,7 @@ static int ep_modify(struct eventpoll *ep, struct epitem *epi, struct epoll_even
>>>        * Get current event bits. We can safely use the file* here because
>>>        * its usage count has been increased by the caller of this function.
>>>        */
>>> +     smp_mb();
>>>       revents = epi->ffd.file->f_op->poll(epi->ffd.file, &pt);
>>>
>>>       /*
>>
>> I was wrong, rereading 626cf236608505d376e4799adb4f7eb00a8594af,
>> I think this race existed before.
>>
>> Perhaps my alternate patch above is a better fix.
>
> Please document the barrier that this mb() pairs with, and then give
> an explanation for the fix in the commit message, and I'll happily
> take it. Even if it's just duplicating the comments above the
> wq_has_sleeper() function, except modified for the ep_modify() case.
>
> Of course, it would be good to get verification from Jason and Andreas
> that the alternate patch also works for them.
>
>                Linus
