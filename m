From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sun, 09 Jul 2006 11:00:32 -0400
Message-ID: <1152457232.5124.127.camel@jzny2>
References: <20060630234512.GR14627@postel.suug.ch>
	 <1151722785.5093.51.camel@jzny2> <20060701112833.GS14627@postel.suug.ch>
	 <1151760901.5093.141.camel@jzny2> <20060708105451.GG14627@postel.suug.ch>
	 <1152368076.5272.39.camel@jzny2> <20060708234602.GH14627@postel.suug.ch>
	 <1152449536.5124.31.camel@jzny2> <20060709133327.GK14627@postel.suug.ch>
	 <1152453796.5124.70.camel@jzny2>  <20060709141933.GM14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:22752 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1161017AbWGIPAn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 11:00:43 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fzam6-0005Wq-2d
	for netdev@vger.kernel.org; Sun, 09 Jul 2006 11:00:46 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060709141933.GM14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-09-07 at 16:19 +0200, Thomas Graf wrote:
> * Jamal Hadi Salim <hadi@cyberus.ca> 2006-07-09 10:03
> > On Sun, 2006-09-07 at 15:33 +0200, Thomas Graf wrote:
> > > That's not gonna work, dev->queue_lock may be held legimitately
> > > by someone else than an underlying dev_queue_xmit() call.
> > > 
> > 
> > If there is a legitimate reason then it wont work. I cant think of one
> > though.
> 
> See sch_generic.c, it's documented. A simple grep on queue_lock
> would have told you the same.
> 

If you mean that the device will also try to grab the qlock there, then
that is fine still for the serialization. It all starts at
dev_queue_xmit.

> > This is also another approach that would work. If you think its simpler
> > go ahead and shoot a patch.
> 
> It's not simpler, it's correct, while your patch is wrong.
> 

Ok, calm down, will you? Man, you make it very hard to follow Daves
Tibetan approach. Let me tell you exactly how i feel about your
approach: It is unnecessarily complex. The approach i posted is not only
fine, it works with only 4-5 lines of code; i have numerous tests
against it over a long period of time. I was trying to be polite and
follow Daves advice not to insist it has to be done my way - it almost
seems impossible with you trying to nitpick on little unimportant
details.

> > A->*->A is a no-no.
> > And in some cases it is fine to let the user just fsck themselves
> > because then they will understand it is a bad idea [1] when shit
> > happens. OTOH, if there was a KISS way of doing it (as in the ifb case,
> > why not).
> 
> I remind you that you started mentioning this A->*->A case while
> talking about tx deadlocks that were supposed to be prevented with
> the !from check or something along that lines. I can't really tell
> because you explain it differently in every posting.
> 

Because you are looking for preciseness at the micro/code level and i am
trying to explain at the conceptual/macro level (I have to adjust to
your mode but it is hard for me because i dont think at our level that
matters). When i sense you didnt understand me the last time, I try to
explain it better. The deadlock happens on transmit. If you want to be
precise, it happens when dev_queue_xmit is invoked. If you want more
preciseness, when the queue lock is contended. If you want more
preciseness, the code sample that i showed you should help illustrate
it.

> > Yes, of course otherwise i wouldnt bother to comment on any patches.
> 
> So maintain the code and fix your bugs.

Ok, I dont think this is gonna work - I may have to give up on getting
any resolution. 

Heres the suggestion again and you can still shoot a patch:
- If we can avoid doing anything at mirred that is the most preferable
approach. i.e get the change for free. In other words if it complicates
things it is not worth it. Someone redirecting eth0 to eth0 on egress
deserves whats happening to them.

- Try it against Herberts patch. It may resolve something or may require
an adjustment to Herberts patch so we can kill two birds with one stone
i.e get it for free. I dont know. I guess i shouldnt say "i dont know"
it is not precise, my point is you may find things when you attempt the
change. The patch is in Daves 2.6.18 tree.

- Iam fine with your suggestion to use a flag. The problem is not which
scheme you use - it is whether the change at such a crucial path in the
stack would be acceptable to other people.

Anyways, I am off.

cheers,
jamal

