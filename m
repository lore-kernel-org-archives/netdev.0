From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH net-next 09/14] gtp: Allow configuring GTP interface as standalone
Date: Wed, 20 Sep 2017 17:55:01 -0700
Message-ID: <CAPDqMeox74aEdV5_cr7HJ=kh0-etLdFE-u5=g8OqRzmS8OjOuQ@mail.gmail.com>
References: <20170919003904.5124-1-tom@quantonium.net> <20170919003904.5124-10-tom@quantonium.net>
 <a6d1dad0-e922-2913-d4c8-592d403ee1cb@tpip.net> <CALx6S3771X4QUm2mJG=aJJ0f4Tm98NpGA7060vF1P8iuCPgicQ@mail.gmail.com>
 <56e339a8-fa2d-6f8d-a89c-c0f3f242763a@tpip.net> <CAPDqMeq1tLi=NkLyqma2OEHQi-fYEYeTU-8th9WKoZaeWiM0Rw@mail.gmail.com>
 <20170921001313.n2uo56oxmphcvd5g@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andreas Schultz <aschultz@tpip.net>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Rohit Seth <rohit@quantonium.net>
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:49103 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbdIUAzD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 20:55:03 -0400
Received: by mail-wr0-f179.google.com with SMTP id 108so3395031wra.5
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 17:55:02 -0700 (PDT)
In-Reply-To: <20170921001313.n2uo56oxmphcvd5g@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 5:13 PM, Harald Welte <laforge@gnumonks.org> wrote:
> Hi Tom,
>
> On Wed, Sep 20, 2017 at 09:24:07AM -0700, Tom Herbert wrote:
>> On Wed, Sep 20, 2017 at 9:07 AM, Andreas Schultz <aschultz@tpip.net> wrote:
>> > GTP isn't special, I just don't like to have testing only features in there
>> > when the same goal can be reached without having to add extra stuff. Adding
>> > code that is not going to be useful in real production setups (or in this
>> > case would even break production setups when enabled accidentally) makes the
>> > implementation more complex than it needs to be.
>>
>> Well, you could make the same argument that allowing GTP to configured
>> as standalone interface is a problem since GTP is only allowed to be
>> with used with GTP-C. But, then we have something in the kernel that
>> the community is expected to support, but requires jumping through a
>> whole bunch of hoops just to run a simple netperf.
>
> "A whole bunch of hoops" without your new interface would consist of
> running a single command-line program that is supplied with libgtpnl.
> This is not a complete 3GPP network, but a simple libmnl-based helper
> library with no other depenencies.
>
You have the point of view of someone who has a lot of experience
dealing with this protocol. Try to imagine if you were some random
kernel network programmer with no experience in the area. If they
happen to find a one-off bug and want to do the right thing by running
a test, you want to make that as easy as possible. From that
perspective, building protocol specific libraries and finding the
right cmd line to run is significant hoops (I can attest to this).
There are other examples in the kernel of systems bigger than GTP that
require a whole lot of effort just to run a simple test; you'll notice
for those it's rare that best developers ever bother to look at them
unless they're making a global change that affects the code. We don't
want GTP to take be like that!

> I'm not neccessarily against introducing features like the 'standalone
> interface configuration'.  However, we must make sure that any
> significant new feature contributions like IPv6 are tested in a
> "realistic setup" and not just using those 'interfaces added for easy
> development'.  Also, I would argue those 'interfaces added for easy
> deveopment/benchmarking' should probably be clearly marked as such to
> avoid raising the impression that this is what leads to a
> standard-conforming / production-type setup.
>
Given the obvious complexity of running a real GTP stack, I don't
think we have to worry about this. In order to test a "realistic
setup" a whole bunch of other support is needed. So the forward
looking question now is how to get to be able to run a "realistic
setup"?

Tom
