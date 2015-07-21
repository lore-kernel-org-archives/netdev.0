From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 1/2] tcp: don't extend RTO on failed loss probe attempts
Date: Tue, 21 Jul 2015 10:55:07 -0700
Message-ID: <CAK6E8=dg6VC4QE3OchoSHtf6Ewj-VHchjq-BkV_8P1nEzW2ucw@mail.gmail.com>
References: <1437168172-24201-1-git-send-email-ycheng@google.com>
 <1437168172-24201-2-git-send-email-ycheng@google.com> <1437197265.1026.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vn0-f52.google.com ([209.85.216.52]:34570 "EHLO
	mail-vn0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbbGURzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 13:55:47 -0400
Received: by vnds125 with SMTP id s125so38796241vnd.1
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 10:55:47 -0700 (PDT)
In-Reply-To: <1437197265.1026.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2015 at 10:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> On Fri, 2015-07-17 at 14:22 -0700, Yuchung Cheng wrote:
> > If TLP was unable to send a probe, it extended the RTO to
> > now + icsk_rto. But extending the RTO makes little sense
> > if no TLP probe went out. With this commit, instead of
> > extending the RTO we re-arm it relative to the transmit time
> > of the write queue head.
>
> But what was the reason the probe could not be sent ?
>
> If it is local congestion or memory allocation error, it does make sense
> to not add fuel to the fire.
Good point. We can identify those so we don't attempt to
retransmit on these errors, but will retransmit on receive-window
limit. I'll re-spin the patch.

>
>
>
