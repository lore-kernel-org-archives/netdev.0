From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC v3 0/8] xdp: Infrastructure to generalize XDP
Date: Tue, 21 Feb 2017 18:54:53 -0800
Message-ID: <CALx6S36bujuFmDkvG8V5cuigbeNpJX-nprL1_1Ub+m4AiV3Lqw@mail.gmail.com>
References: <20170221193417.3641224-1-tom@herbertland.com> <20170221150907.5ae68ffa@cakuba.netronome.com>
 <CALx6S34aOhKt7JS=3tbweMm1pf3gnr4WU1ZnjOUc5-wP+xCuyA@mail.gmail.com>
 <20170221172939.432b9c9b@cakuba.netronome.com> <CALx6S358XOdPXjHUNUdnrsK-qmDVkmZXWacy1OPBJudVz31OCw@mail.gmail.com>
 <20170221182341.4b2dd0c8@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:34839 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753186AbdBVCyy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 21:54:54 -0500
Received: by mail-qt0-f172.google.com with SMTP id x35so54268582qtc.2
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 18:54:54 -0800 (PST)
In-Reply-To: <20170221182341.4b2dd0c8@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 6:23 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Tue, 21 Feb 2017 18:04:49 -0800, Tom Herbert wrote:
>> On Tue, Feb 21, 2017 at 5:29 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
>> > On Tue, 21 Feb 2017 16:25:15 -0800, Tom Herbert wrote:
>> >> >>   - Provides a more structured environment that is extensible to new
>> >> >>     features while being mostly transparent to the drivers
>> >> >
>> >> > So far all features we added required explicit driver support.
>> >> > Checksumming support as an example will require driver changes, too.
>> >> > Generalized way to call programs is probably not going to buy us much?
>> >> >
>> >> Hi Jakub,
>> >>
>> >> What is the the concern with checksumming? Isn't that just an issue of
>> >> defining fields in xdp_data and driver populating with the appropriate
>> >> information?
>> >
>> > Thanks for replying!  I was just using checksumming as an example.  I
>> > was trying to counter the argument that the hook infrastructure will
>> > allow for features to be implemented mostly transparently to theom
>> > drivers.  I may be wrong but it seems that it doesn't buy us anything
>> > as far as the features which were so far discussed go.
>>
>> But I still don't understand the example. In the case of checksumming
>> the driver just needs to populate the values in xdp_data regarding
>> csum. We could basically reuse the same interface as that in skbuff.
>> The stack then can handle the logic of verifying checksums (verifying
>> a csum-complete value for instance). The driver only passes
>> information to the stack concerning a packet, it doesn't need to act
>> on the information. For instance, it's not the driver's prerogative to
>> verify the checksum itself. In general the less drivers have to do and
>> the more we push complexity of common functionality into the stack,
>> the better.
>
> Sorry, I thought your patchset abstracts away populating struct xdp.
> So my initial statement should have read "Checksumming will require
> driver changes, only".  Yes, drivers will just have to populate the
> appropriate XDP buffer field.  What are the XDP features you foresee
> this hook infrastructure to help drivers with?

It is part of the direction to take XDP beyond the first use case of
BPF and leverage the high performance processing model in a much
broader context. For instance, as Saeed alluded to we should be a able
to create an skb-less interface into the stack-- this is essentially
what we need for TXDP (expedited processing for the transport layer).
Also, I think that we should also be able to extrapolate a good RX
batch interface from an API like this (please see discussion on that).

Thanks,
Tom
