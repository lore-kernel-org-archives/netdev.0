From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: List corruption on epoll_ctl(EPOLL_CTL_DEL) an AF_UNIX socket
Date: Thu, 01 Oct 2015 11:33:59 +0100
Message-ID: <87oagiho88.fsf@doppelsaurus.mobileactivedefense.com>
References: <20150913195354.GA12352@jig.fritz.box>
	<20150914023949.GA15012@dcvr.yhbt.net>
	<CA+rthh8smc0fxL5sEhMpKRQgzMi=BCVyxKc=O1JWesHGwYW8XA@mail.gmail.com>
	<560AE202.4020402@akamai.com>
	<CA+rthh9XU+5oN9Ua-+8XPF9Q0y03FZyxds53sxUjsvsJN2kaJA@mail.gmail.com>
	<560C9CFE.6090509@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mathias Krause <minipli@googlemail.com>, netdev@vger.kernel.org,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Wong <normalperson@yhbt.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"peterz\@infradead.org" <peterz@infradead.org>,
	"davem\@davemloft.net" <davem@davemloft.net>
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:39308 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751140AbbJAKfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 06:35:11 -0400
In-Reply-To: <560C9CFE.6090509@akamai.com> (Jason Baron's message of "Wed, 30
	Sep 2015 22:39:58 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason Baron <jbaron@akamai.com> writes:
> On 09/30/2015 01:54 AM, Mathias Krause wrote:
>> On 29 September 2015 at 21:09, Jason Baron <jbaron@akamai.com> wrote:
>>> However, if we call connect on socket 's', to connect to a new socket 'o2', we
>>> drop the reference on the original socket 'o'. Thus, we can now close socket
>>> 'o' without unregistering from epoll. Then, when we either close the ep
>>> or unregister 'o', we end up with this list corruption. Thus, this is not a
>>> race per se, but can be triggered sequentially.
>> 
>> Sounds profound, but the reproducers calls connect only once per
>> socket. So there is no "connect to a new socket", no?
>> But w/e, see below.
>
> Yes, but it can be reproduced this way too. It can also happen with a
> close() on the remote peer 'o', and a send to 'o' from 's', which the
> reproducer can do as pointed out Michal. The patch I sent deals with
> both cases.

As Michal also pointed out, there's a unix_dgram_disconnected routine
being called in both cases and insofar "deregistering" anything beyond
what unix_dgram_disconnected (and - insofar I can tell this -
unix_release_sock) already do is actually required, this would be the
obvious place to add it. A good step on the way to that would be to
write (and post) some test code which actually reproduces the problem in
a predictable way.
