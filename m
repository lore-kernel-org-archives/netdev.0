From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 2/2] bonding: make hard-coded defines
 configurable at build
Date: Tue, 15 Jul 2014 21:18:11 +0200
Message-ID: <20140715191810.GA16963@mikrodark.usersys.redhat.com>
References: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
 <1405419341-31510-3-git-send-email-vfalico@gmail.com>
 <CAADnVQJCNJVTBFkinNzo=1mSWEBhif3dOVnVvuievJxijtNb7w@mail.gmail.com>
 <20140715161802.GC5225@mikrodark.usersys.redhat.com>
 <CAADnVQJaUQsDF1--4ffnCUz=1Tw1Ox=kgUw3h1L1EnrDs0WQfw@mail.gmail.com>
 <20140715171139.GD5225@mikrodark.usersys.redhat.com>
 <CAADnVQKPJTHFGdCRtbQHLAg_NpDkKQ+8WVwfkic8KE+dQxZw2g@mail.gmail.com>
 <20140715175331.GA14109@mikrodark.usersys.redhat.com>
 <CAADnVQKeFOhbZOSHtpodnWb6OXem79jjozHm=Qgzz8PyVTryRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:42988 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932760AbaGOTVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 15:21:09 -0400
Received: by mail-wi0-f181.google.com with SMTP id bs8so112485wib.8
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 12:21:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAADnVQKeFOhbZOSHtpodnWb6OXem79jjozHm=Qgzz8PyVTryRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 11:55:29AM -0700, Alexei Starovoitov wrote:
>On Tue, Jul 15, 2014 at 10:53 AM, Veaceslav Falico <vfalico@gmail.com> wrote:
>> On Tue, Jul 15, 2014 at 10:33:25AM -0700, Alexei Starovoitov wrote:
>> ..snip...
>>
>>> For 3 vlan case to be useful, first somebody needs to define a meaning
>>> for it and real use case. I haven't seen one.
>>
>>
>> You also haven't seen switches that support it, however juniper switches do
>> support them, as a quick google shows. I can guess that cisco can also be
>> made to support them.
>
>I don't think juniper switches support them either.
>Please send the link to the spec.

No spec, but a reply from a juniper employee, as it states:

http://forums.juniper.net/t5/Ethernet-Switching/Is-it-possible-to-do-QinQinQ/td-p/29409

Also, it's a valid use case, described there.

>Protocol parsers in HW fail to parse beyond two, since behavior
>is undefined and it's considered invalid packet.
>I'm talking about broadcom/intel/cisco asics.

You're mentioning it for the 3rd or 4th time already. Can you please
provide a proof? It'd be interesting to read, as I see over the net that
people are managing to do triple vlan tagging on cisco.

Also, could you explain what do you mean by "undefined behaviour"? I can't
really understand what can be undefined in 3 tags.

>Generally speaking I think it's a mistake of linux stack to support
>any nested level. Not too long ago we saw issues with broken hw
>offloads for basic qinq. I won't be surprised if creating triple stacked
>vlan devices actually breaks all sort of things.

That's not the problem with any nested vlan level, but with hw offload. I
guess it's the source/consiquencies thing.

>
>> I'll happily drop any/all of these configs if I'd see a reason NOT to add
>> them. Till now I haven't seen anything except "I don't know why should I
>> use it", and that's not a valid reason to me, sorry.
>
>correct. I don't see a good reason to change these defaults and you also
>seem to acknowledge the same.

You're putting words in my mouth for the second time already. I didn't say
that I don't see a good reason to change the defaults, I've said that I
don't see a good reason to drop this enhancement only because someone
doesn't know what to use it for.

>To me it's a red flag when somebody
>requests a feature without proper justification.

The feature is there already. It's just a configuration to enable this
feature without changing one define.

And, also, the any-level nesting in linux stack *is* already present, and
bonding just tries to stay up-to-date with that.
