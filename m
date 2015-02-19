From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: smsc95xx truesize badness
Date: Thu, 19 Feb 2015 14:14:02 -0800
Message-ID: <1424384042.4942.132.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAKh2mn7w8fpSYJQqwxwOiAgzKm_5dtzY_uXG7WK7uO9CXSOTrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, popcorn mix <popcornmix@gmail.com>
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:39778 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbbBSWOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 17:14:05 -0500
Received: by iecvy18 with SMTP id vy18so3620368iec.6
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 14:14:04 -0800 (PST)
In-Reply-To: <CAKh2mn7w8fpSYJQqwxwOiAgzKm_5dtzY_uXG7WK7uO9CXSOTrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-19 at 18:58 +0000, Steve Glendinning wrote:

> This is triggering warnings for many Raspberry Pi users due to Eric's
> patch to catch truesize offenders.  It's a fair cop.
> 
> Before I submit a patch to remove these two truesize lines, I believe
> it's safe to just do so but can anyone confirm if removing them will
> have any adverse impact?

If you simply remove the lines, skb->truesize might be big enough to
slow down TCP noticeably.

I would rather use something like commit
a9e0aca4b37885b5599e52211f098bd7f565e749
("asix: asix_rx_fixup surgery to reduce skb truesizes")

Idea is to 'copybreak' tiny frames.
