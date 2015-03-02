From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v4 0/2] net: Introducing socket mark receive
 socket option
Date: Mon, 2 Mar 2015 15:48:58 +0200
Message-ID: <CAHsH6Gu+ZHSdnnritKk5cjTg4NuKppYjffXjNpou2i+uVeykYA@mail.gmail.com>
References: <1425302043-669-1-git-send-email-eyal.birger@gmail.com>
	<20150302132925.GB7418@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:43749 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbbCBNs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 08:48:59 -0500
Received: by ykp9 with SMTP id 9so13387965ykp.10
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 05:48:58 -0800 (PST)
In-Reply-To: <20150302132925.GB7418@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 2, 2015 at 3:29 PM, Florian Westphal <fw@strlen.de> wrote:
> Eyal Birger <eyal.birger@gmail.com> wrote:
>> This patch set introduces a new socket option for fetching the mark
>> of skbs passed to sockets as ancillary data.
>>
>> A userspace program may wish to receive the mark of packets it
>> receives, for example for distinguishing between different TPROXY
>> diversion rules to the same userspace proxy socket.
>
> Hmm... Whats the use case?
> Even if you cannot use multiple sockets for every divert rule,
> TPROXY doesn't mangle payload; applications could use sockaddrs
> returned by accept, getpeername, getsockname etc.  to figure out
> which original port/address the packet was sent to?

Right. But that would mean the criteria for traffic diversion would need to
be known to the application receiving the traffic. IMHO It is a more elegant
solution to use the mark in order to distinguish between different traffic flows
instead of duplicating the match logic.

Also, the feature has use-cases outside of TPROXY as the skb->mark may be set
by other mechanisms (including SO_MARK from user space).

For example, a user space daemon can receive traffic from multiple
applications using
a single socket and distinguish between different traffic groups
according to the packet
mark.

Regards,
Eyal.
