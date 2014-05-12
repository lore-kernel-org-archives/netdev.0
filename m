From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC net-next 0/4] Support UID range routing.
Date: Tue, 13 May 2014 05:25:32 +0900
Message-ID: <CAKD1Yr259v2uCw_FAQ9AqELP0NqjrvOB2pCm7hNWnKRW1T8NLg@mail.gmail.com>
References: <20140428.125807.409036177577836732.davem@davemloft.net>
 <CAKD1Yr1HN4=42JYfe9LYguWukXxNE38vvwLBt-aEeQ-zSisN9Q@mail.gmail.com>
 <CAKD1Yr0wqj0wG3Ges9NeqMBALO-SxY9KTgZo_sp_8VYKnihKMQ@mail.gmail.com>
 <20140502.152441.695810627123047.davem@davemloft.net> <CAKD1Yr24VnDU9swPzq67uocFvyD2EOkLVT0Ph7Xwkq=wGkzNgQ@mail.gmail.com>
 <1399454661.19449.114587073.05E84176@webmail.messagingengine.com>
 <CAKD1Yr0ZXniXMyZ3WcWFsZ=UD9JJ+Bhv69meRrGuMEiN-_SugA@mail.gmail.com> <1399844745.13956.116157949.32873A56@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	David Newall <davidn@davidnewall.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	JP Abgrall <jpa@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:65274 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855AbaELUZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 16:25:53 -0400
Received: by mail-ie0-f180.google.com with SMTP id as1so7506076iec.39
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 13:25:53 -0700 (PDT)
In-Reply-To: <1399844745.13956.116157949.32873A56@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2014 at 6:45 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>> It would require defining a new identifier, figuring out what its
>> semantics are, setting it when socket objects are created, attaching
>> it to sockets across accept/fork, etc. Userspace code would have to be
>> update it to set it on processes (whereas the uid is already dealt
>> with by existing tools), etc.
>
> That was my idea, yes. Having some kind of opaque identifier with
> user-friendly names a la /etc/iproute2/rt_tables which can be used in ip
> rule matches.
>
> I see, it would require very heavy lifting, but in the end seems to be
> more user-friendly to me than uids.

Well, I don't know. Today we have an iptables module in tree that does
UID matching, which means that presumably people do find it useful. In
addition to the Android use case there seem to be other people doing
it as well [1][2][3]. On the other hand, we don't have a similar one
for PIDs or a generic "fib grouo". nftables meta seems to support UID
and gid, but not PID.

For people that currently use the socket owner to do routing, this
patch is a strictly better way to do it, because it doesn't have any
of the drawbacks of NAT (information in the socket structures that
doesn't correspond to reality; more conntrack state; NAT breaking
end-to-end; etc.).

Whether a new fibgroup option would serve these use cases better is
hard to say. If what people want to do is per-process, then perhaps an
opaque fibgroup is better. But if what they actually want to do is
per-user, then if you implement fibgroups you still have to build
machinery in userspace to make sure that each user's processes got put
into the right fib group.

[1] http://blog.sebastien.raveau.name/2009/04/per-process-routing.html
[2] http://arstechnica.com/civis/viewtopic.php?f=16&t=1195455
[3] http://www.niftiestsoftware.com/2011/08/28/making-all-network-traffic-for-a-linux-user-use-a-specific-network-interface/
