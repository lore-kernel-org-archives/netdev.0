From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next 0/4] Support UID range routing.
Date: Wed, 07 May 2014 02:24:21 -0700
Message-ID: <1399454661.19449.114587073.05E84176@webmail.messagingengine.com>
References: <20140428.125807.409036177577836732.davem@davemloft.net>
 <CAKD1Yr1HN4=42JYfe9LYguWukXxNE38vvwLBt-aEeQ-zSisN9Q@mail.gmail.com>
 <CAKD1Yr0wqj0wG3Ges9NeqMBALO-SxY9KTgZo_sp_8VYKnihKMQ@mail.gmail.com>
 <20140502.152441.695810627123047.davem@davemloft.net>
 <CAKD1Yr24VnDU9swPzq67uocFvyD2EOkLVT0Ph7Xwkq=wGkzNgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Newall <davidn@davidnewall.com>, netdev@vger.kernel.org,
	JP Abgrall <jpa@google.com>
To: Lorenzo Colitti <lorenzo@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from new2-smtp.messagingengine.com ([66.111.4.224]:56180 "EHLO
	new2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932265AbaEGJYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 05:24:22 -0400
In-Reply-To: <CAKD1Yr24VnDU9swPzq67uocFvyD2EOkLVT0Ph7Xwkq=wGkzNgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, May 6, 2014, at 20:59, Lorenzo Colitti wrote:
> This doesn't just affect the source address, it similarly affects any
> other parameters that are taken from route lookups and stored in the
> socket, such as MSS, initial cwnd / rwnd / RTO, etc. Some (like MSS)
> can be fixed up with netfilter, but not all. Also, every connection
> made through this scheme takes up conntrack state, is affected by
> conntrack timeouts, etc.

I question the abstraction of using UIDs for matching routing rules.
E.g. freebsd uses setfib[1] to alter the view of the routing table per
process. E.g. an interface like ip rule exec (action ACTION)+ PROGRAM
would be much nicer in combination with a prctl, maybe? I would much
rather enjoy an interface not based on UIDs. Would something like that
solve your initial problem?

The other possibility that came to my mind would be that it is possible
to share interfaces and ip addresses per netns but it seems more
difficult to implement.

Greetings,

  Hannes

[1]
http://www.freebsd.org/cgi/man.cgi?query=setfib&apropos=0&sektion=0&manpath=FreeBSD+10.0-RELEASE&arch=default&format=html
