From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next 0/4] Support UID range routing.
Date: Sun, 11 May 2014 14:45:45 -0700
Message-ID: <1399844745.13956.116157949.32873A56@webmail.messagingengine.com>
References: <20140428.125807.409036177577836732.davem@davemloft.net>
 <CAKD1Yr1HN4=42JYfe9LYguWukXxNE38vvwLBt-aEeQ-zSisN9Q@mail.gmail.com>
 <CAKD1Yr0wqj0wG3Ges9NeqMBALO-SxY9KTgZo_sp_8VYKnihKMQ@mail.gmail.com>
 <20140502.152441.695810627123047.davem@davemloft.net>
 <CAKD1Yr24VnDU9swPzq67uocFvyD2EOkLVT0Ph7Xwkq=wGkzNgQ@mail.gmail.com>
 <1399454661.19449.114587073.05E84176@webmail.messagingengine.com>
 <CAKD1Yr0ZXniXMyZ3WcWFsZ=UD9JJ+Bhv69meRrGuMEiN-_SugA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	David Newall <davidn@davidnewall.com>, netdev@vger.kernel.org,
	JP Abgrall <jpa@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from new2-smtp.messagingengine.com ([66.111.4.224]:44647 "EHLO
	new2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755717AbaEKVps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 17:45:48 -0400
In-Reply-To: <CAKD1Yr0ZXniXMyZ3WcWFsZ=UD9JJ+Bhv69meRrGuMEiN-_SugA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2014, at 3:58, Lorenzo Colitti wrote:
> On Wed, May 7, 2014 at 6:24 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > I question the abstraction of using UIDs for matching routing rules.
> > E.g. freebsd uses setfib[1] to alter the view of the routing table per
> > process. E.g. an interface like ip rule exec (action ACTION)+ PROGRAM
> > would be much nicer in combination with a prctl, maybe? I would much
> > rather enjoy an interface not based on UIDs. Would something like that
> > solve your initial problem?
> 
> So you're suggesting something that would still be an ip rule, but
> would match a new identifier ("fibgroup") rather than the uid? I think
> that would work, though obviously it's a much bigger change than what
> I am proposing here.
> 
> It would require defining a new identifier, figuring out what its
> semantics are, setting it when socket objects are created, attaching
> it to sockets across accept/fork, etc. Userspace code would have to be
> update it to set it on processes (whereas the uid is already dealt
> with by existing tools), etc.

That was my idea, yes. Having some kind of opaque identifier with
user-friendly names a la /etc/iproute2/rt_tables which can be used in ip
rule matches.

I see, it would require very heavy lifting, but in the end seems to be
more user-friendly to me than uids. But I guess task_struct is something
like sk_buff, where you need to find very good arguments to expand it.

Maybe something like cgroup/net_cls.classid would be possible, but I am
not familar on how to interact with cgroups internally and don't know
how much work that would be (and if more network cgroup interaction is
actually desirable).

> If you're proposing something not that's not an ip rule, then that
> seems like a step backwards, because it won't allow the rich policy
> allowed by processing rules in priority order, throw routes, FRA_GOTO,
> etc.

Agreed.

Bye,

  Hannes
