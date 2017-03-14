From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] net: ipv4: add support for ECMP hash policy choice
Date: Tue, 14 Mar 2017 15:38:40 -0700
Message-ID: <CAJieiUgQpOidyE-OH73QQpMcQnzEgd+9bGPOKA-yAaFtb3fcwQ@mail.gmail.com>
References: <1489505775-2913-1-git-send-email-nikolay@cumulusnetworks.com>
 <20170314085502.47d48a4e@xeon-e3> <8088fe5f-0c0b-bdba-4fba-e9e28bbed02e@cumulusnetworks.com>
 <20170314.114837.619141079617104809.davem@davemloft.net> <20170314132506.6233b1e7@xeon-e3>
 <CAJieiUjeYH=u6W5p18JA=RwKuFpX6HSrifD0fRE1rR2e0fsvhw@mail.gmail.com> <20170314144204.20d5c3a5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>, jkbs@redhat.com,
        Eric Dumazet <edumazet@google.com>,
        Peter Christensen <pch@ordbogen.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f178.google.com ([209.85.217.178]:34993 "EHLO
        mail-ua0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750932AbdCNWim (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 18:38:42 -0400
Received: by mail-ua0-f178.google.com with SMTP id q7so141134uaf.2
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 15:38:41 -0700 (PDT)
In-Reply-To: <20170314144204.20d5c3a5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 2:42 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue, 14 Mar 2017 14:10:22 -0700
> Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>
>> On Tue, Mar 14, 2017 at 1:25 PM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>> > On Tue, 14 Mar 2017 11:48:37 -0700 (PDT)
>> > David Miller <davem@davemloft.net> wrote:
>> >
>> >> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

[snip]


>> >> > That's what my initial version did, but this was discussed during NetConf in Seville
>> >> > and it was decided that it's best to make a global sysctl, thus the change.
>> >>
>> >> Correct, we discussed this, and we all agreed to only have a sysctl for now.
>> >
>> > Why? If you are going to have private discussions please post the rationale
>> > in public.
>>
>> Stephen, is there any reason to have a per ecmp route multipath algo
>> selection ?.
>> All platforms have a global multipath selection algo. I also don't see
>> routing daemons ready or willing to specify a per ecmp route multipath
>> selection algo attribute.
>
> There is no compelling reason to make the attribute per route. But the
> issue is more that configuration through sysctl's is problematic. It doesn't
> fit into the standard API paradigm. Sysctl's are like routing patches not
> part of the real CLI. Trying to trap sysctl's for things like switchedev
> offload is particularly problematic. I can see the case for either way,
> and don't have a fixed opinion.

ok. understand the switchdev offload part. It was that way in the past...but
today you can listen to sysctl updates on the netconf netlink channel.
it works pretty well.

>
> The bigger discussion is trying to keep a record of the rationale for decisions
> such that there isn't buried tribal knowledge. This is why Dave has always been
> quite insistent on having discussions on the mailing list. There doesn't seem to
> be a good long term record other than Documentation/networking or commit logs.
>

agree. Most of the discussion around this has happened on the netdev
mailing list so far.
The previous set that updated ecmp algo tried to add a per route
attribute and after review on this list was moved to
on by default. Nikolay's first version included a per route
attribute...to follow the previous ecmp work.
Before Nikolay posted the second version, my feedback was to make it
global. And this feedback was only re-iterated at
last netconf/netdev. so, we can continue the discussion here if there
are other opinions.
