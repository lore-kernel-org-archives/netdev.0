From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: smsc95xx truesize badness
Date: Fri, 20 Feb 2015 06:41:09 -0800
Message-ID: <1424443269.5565.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAKh2mn7w8fpSYJQqwxwOiAgzKm_5dtzY_uXG7WK7uO9CXSOTrw@mail.gmail.com>
	 <1424384042.4942.132.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, popcorn mix <popcornmix@gmail.com>
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34536 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754826AbbBTOlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 09:41:12 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so3451472igb.3
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 06:41:11 -0800 (PST)
In-Reply-To: <1424384042.4942.132.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-19 at 14:14 -0800, Eric Dumazet wrote:
> On Thu, 2015-02-19 at 18:58 +0000, Steve Glendinning wrote:
> 
> > This is triggering warnings for many Raspberry Pi users due to Eric's
> > patch to catch truesize offenders.  It's a fair cop.
> > 
> > Before I submit a patch to remove these two truesize lines, I believe
> > it's safe to just do so but can anyone confirm if removing them will
> > have any adverse impact?
> 
> If you simply remove the lines, skb->truesize might be big enough to
> slow down TCP noticeably.
> 
> I would rather use something like commit
> a9e0aca4b37885b5599e52211f098bd7f565e749
> ("asix: asix_rx_fixup surgery to reduce skb truesizes")
> 
> Idea is to 'copybreak' tiny frames.
> 

On smsc95xx.c, rx_urb_size is set to :

MAX_SINGLE_PACKET_SIZE (2048) on non turbo mode
DEFAULT_HS_BURST_CAP_SIZE (more than 18 KB) on USB_SPEED_HIGH mode
DEFAULT_FS_BURST_CAP_SIZE  (more than 7 KB)

So only non turbo mode would be okay with non copybreak strategy.
