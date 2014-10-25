From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] tcp: Add TCP_FREEZE socket option
Date: Sat, 25 Oct 2014 23:29:42 +0200
Message-ID: <CAKfDRXiuchgvG-vnZ-nuH+_2=rPtXD8Lde1zaUf+u57r0b+RGA@mail.gmail.com>
References: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
	<20141022.121418.1477947755244353588.davem@davemloft.net>
	<CAKfDRXgARYe3hw3vgpgup1X4bNjH0cpwYOfKUZK51HcOf2jeJA@mail.gmail.com>
	<CAPh34mechU=aUS422OBFhHUt68Nk2PZBsMiLPw8eLwS_4PnRtw@mail.gmail.com>
	<CAKfDRXhJ9c+AqqrD38e7RcUSXn21pNMWskRs38H+PnSEwXac+Q@mail.gmail.com>
	<CAK6E8=fiHrgicTXy2hBGh0GUcZRWWxpYxw_bNVmRD+ueN9mUdw@mail.gmail.com>
	<CAPh34mdeYib4VSDT7Fj9i-oNc4c8HmUGT9KHpU2gS4scpODdpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f45.google.com ([209.85.213.45]:45827 "EHLO
	mail-yh0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbaJYV3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 17:29:43 -0400
Received: by mail-yh0-f45.google.com with SMTP id f73so2770663yha.18
        for <netdev@vger.kernel.org>; Sat, 25 Oct 2014 14:29:42 -0700 (PDT)
In-Reply-To: <CAPh34mdeYib4VSDT7Fj9i-oNc4c8HmUGT9KHpU2gS4scpODdpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Oct 24, 2014 at 6:26 PM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
> Yes, starting with fresh values for a new links is a good thing to do.
> But what I think what Kristian want to address is to reduce larger
> idle period due to backoff'ing timeouts followed by larger idle
> periods? E.g. like a temporary cork for an exact period of time.

Yes, that is exactly what I want to achieve. To temporarily stop
traffic while the handover occurs, to prevent the penalty of the
potentially large idle period caused by the sender backing off. With
regards to which values to use when the handover is done, I agree that
it would make sense to start with for example a lower cwnd. The
network characteristics (for example throughput and latency) will most
likely have changed. However, at least the way I have thought about
this, such a change would also need changes on the remote machine.

> I thought that freeze-TCP was *also* designed to bridge a larger
> disconnection? The downside with this approach (compared to SplitTCP)
> is that you only send one instance into sleep. The other peer (sender)
> may run into timeouts too.

Yes, that is true. But I guess with the alternate design (netlink
module), the probability of this will be reduced. As long as the
application sets the frozen socket option and assuming zero window
will arrive, sender should stop as well.

-Kristian
