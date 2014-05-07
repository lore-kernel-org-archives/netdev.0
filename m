From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC net-next 0/4] Support UID range routing.
Date: Wed, 7 May 2014 19:58:10 +0900
Message-ID: <CAKD1Yr0ZXniXMyZ3WcWFsZ=UD9JJ+Bhv69meRrGuMEiN-_SugA@mail.gmail.com>
References: <20140428.125807.409036177577836732.davem@davemloft.net>
 <CAKD1Yr1HN4=42JYfe9LYguWukXxNE38vvwLBt-aEeQ-zSisN9Q@mail.gmail.com>
 <CAKD1Yr0wqj0wG3Ges9NeqMBALO-SxY9KTgZo_sp_8VYKnihKMQ@mail.gmail.com>
 <20140502.152441.695810627123047.davem@davemloft.net> <CAKD1Yr24VnDU9swPzq67uocFvyD2EOkLVT0Ph7Xwkq=wGkzNgQ@mail.gmail.com>
 <1399454661.19449.114587073.05E84176@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	David Newall <davidn@davidnewall.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	JP Abgrall <jpa@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:52760 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932181AbaEGK6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 06:58:30 -0400
Received: by mail-ig0-f173.google.com with SMTP id hn18so7509804igb.6
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 03:58:30 -0700 (PDT)
In-Reply-To: <1399454661.19449.114587073.05E84176@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2014 at 6:24 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> I question the abstraction of using UIDs for matching routing rules.
> E.g. freebsd uses setfib[1] to alter the view of the routing table per
> process. E.g. an interface like ip rule exec (action ACTION)+ PROGRAM
> would be much nicer in combination with a prctl, maybe? I would much
> rather enjoy an interface not based on UIDs. Would something like that
> solve your initial problem?

So you're suggesting something that would still be an ip rule, but
would match a new identifier ("fibgroup") rather than the uid? I think
that would work, though obviously it's a much bigger change than what
I am proposing here.

It would require defining a new identifier, figuring out what its
semantics are, setting it when socket objects are created, attaching
it to sockets across accept/fork, etc. Userspace code would have to be
update it to set it on processes (whereas the uid is already dealt
with by existing tools), etc.

If you're proposing something not that's not an ip rule, then that
seems like a step backwards, because it won't allow the rich policy
allowed by processing rules in priority order, throw routes, FRA_GOTO,
etc.
