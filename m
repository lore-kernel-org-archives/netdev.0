From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the permisions
 of netlink messages
Date: Sun, 25 May 2014 09:27:43 -0700
Message-ID: <CALCETrUHTwGJcV1vVd-Fh2sRdn32CDEc_+_EyrE8c0BYRTyumw@mail.gmail.com>
References: <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org> <536AB151.2070804@dti2.net>
 <CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
 <20140507.185256.496391962242529591.davem@davemloft.net> <CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
 <CA+55aFzZg3LfpPpx3+83sB0npd9863NTMqvsCArMDjg-9J151A@mail.gmail.com>
 <CALCETrVWkW16Y7hOq-mA1auJjRXmwiAUfAGurK0-2bOdbZu_dA@mail.gmail.com>
 <20140522170505.64ef87a2@griffin> <87ioow6pt6.fsf@x220.int.ebiederm.org>
 <CA+55aFxybf=ya2RE5nzf10Km+JZ3=HqXGVCHYcteW2EVAUww+g@mail.gmail.com> <87y4xqtnrq.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Benc <jbenc@redhat.com>,
	David Miller <davem@davemloft.net>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Vivek Goyal <vgoyal@redhat.com>,
	Simo Sorce <ssorce@redhat.com>,
	"security@kernel.org" <security@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f180.google.com ([209.85.128.180]:44019 "EHLO
	mail-ve0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbaEYQ2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2014 12:28:05 -0400
Received: by mail-ve0-f180.google.com with SMTP id db12so8138100veb.25
        for <netdev@vger.kernel.org>; Sun, 25 May 2014 09:28:03 -0700 (PDT)
In-Reply-To: <87y4xqtnrq.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 24, 2014 at 10:45 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Linus Torvalds <torvalds@linux-foundation.org> writes:
>
>> On Fri, May 23, 2014 at 4:25 PM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>>
>>> I have not seen consensus that what Zebra is doing makes sense to
>>> support.
>>
>> Eric, stop right there.
>>
>> There is no "sensible to support". There is only "reality".
>>
>> The thing that makes "reality" be "reality" is that it exists whether
>> you like it or not, or whether you believe in it or not.
>>
>> We don't break applications. Whether you like them or not is
>> completely immaterial.
>
> You stop right there.  You are shooting the messenger.
>
> I like Zebra just fine, and I hate breaking applications.
>
> We don't retain bug compatibility when the semantics of kernel
> interfaces are security vulnerabilities.
>
> I don't appreciate being shot when I am just the messenger saying that
> there is not a known fix for Zebra, that it might be unfixable, and that
> no one had thought of a anything.
>
> What Andy Lutormiski suggested of checking permissions at connect time
> will break a whole lot more than just Zebra.  Unprivileged connect is a
> supported feature in netlink, and all information rtnetlink queries
> are non-privileged as is listening to rtnetlink brodacsts of network
> state chagnes.

I'm suggesting that the connect syscall store creds or maybe just the
outcome of ns_capable(socket's netns, CAP_NET_ADMIN).  Yes, this is
ugly and kludgey.

I suspect that damn near nothing actually calls connect on netlink
sockets, except for my PoC exploit.  Unprivileged sendto and bind are
important features, but they're not the same thing.  In any event, I'm
not actually proposing removing the ability for unprivileged programs
to call connect on netlink sockets.

>
> In concrete form, no special privileges are requires to run "ip link" or
> "ip monitor".  Those among other commands are what Andy has proposed
> breaking, all in the name of "supporting" Zebra.

Nope.  See above.

ip monitor doesn't call connect.  Neither does ip link, at least in
its iproute2 incarnation.

--Andy
