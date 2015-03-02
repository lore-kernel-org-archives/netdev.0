From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v4 0/2] net: Introducing socket mark receive
 socket option
Date: Mon, 2 Mar 2015 20:34:32 +0200
Message-ID: <CAHsH6GtDXWwLP4C2ZTfFpbWyLUKh8=nO02Xg_WmD4a+pN-Vf_A@mail.gmail.com>
References: <1425302043-669-1-git-send-email-eyal.birger@gmail.com>
	<20150302132925.GB7418@breakpoint.cc>
	<CAHsH6Gu+ZHSdnnritKk5cjTg4NuKppYjffXjNpou2i+uVeykYA@mail.gmail.com>
	<20150302143647.GC7418@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:45975 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbbCBSed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 13:34:33 -0500
Received: by ykbq9 with SMTP id q9so2497052ykb.12
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 10:34:33 -0800 (PST)
In-Reply-To: <20150302143647.GC7418@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Mar 2, 2015 at 4:36 PM, Florian Westphal <fw@strlen.de> wrote:
> Eyal Birger <eyal.birger@gmail.com> wrote:
>> On Mon, Mar 2, 2015 at 3:29 PM, Florian Westphal <fw@strlen.de> wrote:
>> > Eyal Birger <eyal.birger@gmail.com> wrote:
>> >> This patch set introduces a new socket option for fetching the mark
>> >> of skbs passed to sockets as ancillary data.
>> >>
>> >> A userspace program may wish to receive the mark of packets it
>> >> receives, for example for distinguishing between different TPROXY
>> >> diversion rules to the same userspace proxy socket.
>> >
>> > Hmm... Whats the use case?
>> > Even if you cannot use multiple sockets for every divert rule,
>> > TPROXY doesn't mangle payload; applications could use sockaddrs
>> > returned by accept, getpeername, getsockname etc.  to figure out
>> > which original port/address the packet was sent to?
>>
>> Right. But that would mean the criteria for traffic diversion would need to
>> be known to the application receiving the traffic.
>
> For your solution to work the application needs to know about the TPROXY
> rule set and how that is structured, no?
>

The application does not need to know about the match criteria. Only about the
eventual mark. This decouples the semantics of a flow and it's actual
match criteria.

> I don't see how that is 'better' than e.g. looking at dst port number.

As mentioned, in cases where the match criteria is more complex than
just the dst
port number, the match logic has to be duplicated in the application.

>
>> Also, the feature has use-cases outside of TPROXY as the skb->mark may be set
>> by other mechanisms (including SO_MARK from user space).
>
> Right, but to me it seems very hacky to use SO_MARK as some kind of OOB signal.
>
> It won't work depending on loaded ruleset, it won't work with non-localhost
> traffic and it won't work when other application runs in another network
> namespace.
>
> Seems such facility would be limited to some pre-configured distribution where
> users don't run own software and make no changes to the default system
> setup.
>

It does not necessarily imply a static configuration, only a carefully
crafted one.
There are more than a few systems with this premise.

>> For example, a user space daemon can receive traffic from multiple
>> applications using a single socket and distinguish between different traffic groups
>> according to the packet mark.
>
> Right, but it might as well use SO_PEERCRED to identify the other pid, right?

I don't think so.

This would only work on connection/pair based sockets (and currently
only supported
in AF_UNIX) - the skb->mark can be different on a per packet basis -
especially when
several applications interact with a single daemon.

Regards,
Eyal.
