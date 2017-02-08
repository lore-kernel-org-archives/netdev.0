From: Tom Herbert <tom@herbertland.com>
Subject: Re: [oss-drivers] Re: [PATCH/RFC net-next 1/2] flow dissector: ND support
Date: Wed, 8 Feb 2017 10:33:46 -0800
Message-ID: <CALx6S36VrtQM5G2XPzpcrP=y3RyBwTnYJcaKqXtwyFgpGiz+Jg@mail.gmail.com>
References: <CALx6S37QtKgc14DFway-Ajme7JhbAN71M+83w28+4FELdv7Xew@mail.gmail.com>
 <20170206091253.GB20384@penelope.horms.nl> <CALx6S351OxEtGhjBdGVGUF7JcBRjpY3hwft-hXjxix7EVAfhQg@mail.gmail.com>
 <20170207.123831.1038511845714033360.davem@davemloft.net> <20170208092823.GA17615@penelope.horms.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33948 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750911AbdBHSfH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 13:35:07 -0500
Received: by mail-qt0-f195.google.com with SMTP id w20so24171080qtb.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 10:33:47 -0800 (PST)
In-Reply-To: <20170208092823.GA17615@penelope.horms.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 8, 2017 at 1:28 AM, Simon Horman <simon.horman@netronome.com> wrote:
> On Tue, Feb 07, 2017 at 12:38:31PM -0500, David Miller wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Tue, 7 Feb 2017 09:36:20 -0800
>>
>> > Okay, but can you give us an idea of how many more of these protocols
>> > are going to be added to flow_dissector. TBH I'm not very enthused
>> > about making more flow_dissector more complex for the benefit of OVS.
>>
>> Especially since the kernel datapath of OVS has been marked
>> experimental.
>
> Hi Dave, Hi Tom,
>
> Firstly I'd like to apologise for posing what has turned out to be a
> somewhat divisive patch.
>
> After looking through things a little more I think the simple answer to
> Tom's question is only ND. But there are also some fields of already
> supported protocols which are covered in the OvS flow key but not the flow
> dissector.
>
> My analysis of OvS flow key fields for non-tunnel packet data - which I
> think is the extent of what is relevant to the flow dissector - yields the
> following list:
>
>   New protocols:
>   * ND (this patch)
>
>   Fields of already supported protocols:
>   * MPLS.lse (currently the label of the LSE is handled by the dissector
>               so this could also be described as MPLS.lse.{tc,s,ttl})
>   * IPV4.tos
>   * IPV4.ttl
>   * IPV6.hlimit
>   * IPV6.tclass
>
>   I do expect that some of the above will not be appropriate for existing
>   users of the flow dissector; e.g. IPV4.ttl does not seem much use when
>   calculating the hash of a flow for steering purposes. And I do not yet
>   have a good idea of how to approach that beyond using different dissector
>   keys.
>
>   Further support for to already supported fields.
>   * IPV[46].frag (supported by flow dissector : 1st frag flag;
>                   not supported by flow dissector: subsequent frag flag)
>
> From my point of view some parts of what is above is more important than
> others. In particular ND is probably not particularly important at least at
> this time. I would be happy to withdraw this patchset if the complexity is
> not deemed worth it at this time.
>
>
> I'd like to take a moment to give a little background and restate that my
> goal is not to create a burden for existing users of the flow dissector
> - or any other part of the stack.
>
> Netronome has worked on various approaches to an upstream offload of OvS.
> One was hooks added to the OvS kernel datapath; an idea which was rejected
> at least twice but none the less I'd be happy to revisit if there is
> interest in it.
>
> The result of trying various approaches is that it seems the most
> acceptable is to use TC for programming flows into hardware which is where
> my work on TC flower and the flow dissector is coming from.  A key part of
> the reasoning being, as I understand it, that the flows could also be
> programmed into hardware for non-OvS use-cases; technology that could be
> useful e.g. in a post-OvS world.
>
It's not an issue specific OVS, it's part of a broader problem in that
we are see more case where the core kernel paths are modified to
support somewhat narrow use case functionality (like OVS, advanced HW
accelerations, etc.). As we have seen recently this can make
maintainability and backports very difficult (see my comments about
backporting mlx5).

> I think the above paragraph gets back to Tom's original question regarding
> making things more complex just for OvS (use-cases). Possibly ND is an edge
> case even for OvS and on reflection my timing for posting it seems to have
> been less than ideal.

If it wasn't ND it would be something else... with all the activity
happening in networking features and HW this is a timely discussion.
Flow dissector presents a good example of a function that might become
a dumping ground for an endless stream of features if we don't figure
out how exercise some restraint.

Tom
