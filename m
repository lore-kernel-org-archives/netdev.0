From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 2/2] bonding: make hard-coded defines
 configurable at build
Date: Tue, 15 Jul 2014 19:53:31 +0200
Message-ID: <20140715175331.GA14109@mikrodark.usersys.redhat.com>
References: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
 <1405419341-31510-3-git-send-email-vfalico@gmail.com>
 <CAADnVQJCNJVTBFkinNzo=1mSWEBhif3dOVnVvuievJxijtNb7w@mail.gmail.com>
 <20140715161802.GC5225@mikrodark.usersys.redhat.com>
 <CAADnVQJaUQsDF1--4ffnCUz=1Tw1Ox=kgUw3h1L1EnrDs0WQfw@mail.gmail.com>
 <20140715171139.GD5225@mikrodark.usersys.redhat.com>
 <CAADnVQKPJTHFGdCRtbQHLAg_NpDkKQ+8WVwfkic8KE+dQxZw2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:55677 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbaGOR43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 13:56:29 -0400
Received: by mail-we0-f181.google.com with SMTP id q59so6017754wes.40
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 10:56:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAADnVQKPJTHFGdCRtbQHLAg_NpDkKQ+8WVwfkic8KE+dQxZw2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 10:33:25AM -0700, Alexei Starovoitov wrote:
..snip...
>For 3 vlan case to be useful, first somebody needs to define a meaning
>for it and real use case. I haven't seen one.

You also haven't seen switches that support it, however juniper switches do
support them, as a quick google shows. I can guess that cisco can also be
made to support them.

You'd be surprised which weird bonding configurations I've seen :).

>Making bond driver support fictitious configuration is pointless.

bond driver *already* supports it, by changing a hardcoded value.

>
>>> Therefore for bond driver there is no reason to accept such packets
>>> in the first place from user space, since they won't go too far in the
>>> network.
>>>
>>>> These defaults are scalable by their nature, and there are people
>>>> maintaining their own patches to change them. So making them available to
>>>> be configured at compile time is a good thing to do, I think.
>>>
>>>
>>> people keep a patch to support 3 vlans? what's the use case?
>>
>>
>> I guess it has something to do with virtualization, including nested one.
>
>sounds like you're inventing a use case instead of having it already.
>imo we shouldn't be adding features because it _feels_ useful.
>use cases gotta be real.

I've got a report asking to make those hardcoded values configurable. I've
never said it was specific to 3 vlans, it was your assumption. I've only
tried to guess one possible way of using it.

>
>> But, again, does this matter? I don't see how it can give us something bad.
>> It's a configuration option with a default value that suits most users, and
>> that might be configured for some advanced/weird use-cases.
>
>it's bad, since it increases test matrix.

Fair enough, and by this way we'll find bugs that otherwise wouldn't be
found because of hardcoded values. That's good for bonding, actually, and
for the networking stack itself.

>You said there are people out there that have some secret patches
>to tweak these defaults. Please share.

I've got a request to make those hardcoded values configurable, as people
tweak them. I don't really care how exactly they tweak them - by using more
arp targets, or less, by tweaking mii default to not failover on first
start if the NICs firmware wasn't fast enough, by using some weird QinQinQ
configurations etc. - because these are values that any power-user can
understand and use, and thus they should be made available to configure
without getting into the code.

I'll happily drop any/all of these configs if I'd see a reason NOT to add
them. Till now I haven't seen anything except "I don't know why should I
use it", and that's not a valid reason to me, sorry.
