From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] tcp: Add TCP_FREEZE socket option
Date: Sat, 25 Oct 2014 23:21:48 +0200
Message-ID: <CAKfDRXh92_3H+8bJ7ieTeYVN7xNHhOzd8YvKZk9N0-_SwusgOA@mail.gmail.com>
References: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
	<20141022.121418.1477947755244353588.davem@davemloft.net>
	<CAKfDRXgARYe3hw3vgpgup1X4bNjH0cpwYOfKUZK51HcOf2jeJA@mail.gmail.com>
	<CAPh34mechU=aUS422OBFhHUt68Nk2PZBsMiLPw8eLwS_4PnRtw@mail.gmail.com>
	<CAKfDRXhJ9c+AqqrD38e7RcUSXn21pNMWskRs38H+PnSEwXac+Q@mail.gmail.com>
	<CAK6E8=fiHrgicTXy2hBGh0GUcZRWWxpYxw_bNVmRD+ueN9mUdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:53295 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbaJYVVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 17:21:49 -0400
Received: by mail-yh0-f49.google.com with SMTP id a41so2774762yho.36
        for <netdev@vger.kernel.org>; Sat, 25 Oct 2014 14:21:48 -0700 (PDT)
In-Reply-To: <CAK6E8=fiHrgicTXy2hBGh0GUcZRWWxpYxw_bNVmRD+ueN9mUdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Sorry for my late reply.

On Fri, Oct 24, 2014 at 4:58 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Do packets actually get dropped during the handover period? if not
> then the sender can detect spurious RTOs and undo the cwnd reductions
> with timestamps or DSACKs (Eifel). Eifel did not exist when the
> freeze-TCP was published at 2000. Even if the connection does not
> support these options as major TCP stacks do, slow-start on a path
> with new BDP isn't that bad of an idea.

Yes, there is 100% is packet loss when several of these handovers
occur. In addition to looking at the pcap-files, I have made some
tests were I send UDP traffic at the same time as TCP. The UDP traffic
does, as expected, resume as soon as the handover is over. The TCP
traffic, on the other hand, recovers when the RTO expires.

Thanks for reminding me about Eifel btw.

-Kristian
