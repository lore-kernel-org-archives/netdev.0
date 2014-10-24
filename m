From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next] tcp: Add TCP_FREEZE socket option
Date: Fri, 24 Oct 2014 18:26:07 +0200
Message-ID: <CAPh34mdeYib4VSDT7Fj9i-oNc4c8HmUGT9KHpU2gS4scpODdpA@mail.gmail.com>
References: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
	<20141022.121418.1477947755244353588.davem@davemloft.net>
	<CAKfDRXgARYe3hw3vgpgup1X4bNjH0cpwYOfKUZK51HcOf2jeJA@mail.gmail.com>
	<CAPh34mechU=aUS422OBFhHUt68Nk2PZBsMiLPw8eLwS_4PnRtw@mail.gmail.com>
	<CAKfDRXhJ9c+AqqrD38e7RcUSXn21pNMWskRs38H+PnSEwXac+Q@mail.gmail.com>
	<CAK6E8=fiHrgicTXy2hBGh0GUcZRWWxpYxw_bNVmRD+ueN9mUdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kristian Evensen <kristian.evensen@gmail.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:57215 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756065AbaJXQ0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 12:26:09 -0400
Received: by mail-la0-f52.google.com with SMTP id hz20so2910730lab.39
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 09:26:07 -0700 (PDT)
In-Reply-To: <CAK6E8=fiHrgicTXy2hBGh0GUcZRWWxpYxw_bNVmRD+ueN9mUdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24 October 2014 16:58, Yuchung Cheng <ycheng@google.com> wrote:

> Do packets actually get dropped during the handover period? if not
> then the sender can detect spurious RTOs and undo the cwnd reductions
> with timestamps or DSACKs (Eifel). Eifel did not exist when the
> freeze-TCP was published at 2000. Even if the connection does not
> support these options as major TCP stacks do, slow-start on a path
> with new BDP isn't that bad of an idea.

Yes, starting with fresh values for a new links is a good thing to do.
But what I think what Kristian want to address is to reduce larger
idle period due to backoff'ing timeouts followed by larger idle
periods? E.g. like a temporary cork for an exact period of time.

I thought that freeze-TCP was *also* designed to bridge a larger
disconnection? The downside with this approach (compared to SplitTCP)
is that you only send one instance into sleep. The other peer (sender)
may run into timeouts too.

Hagen
