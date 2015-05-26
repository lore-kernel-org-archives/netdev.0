From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next 1/3] net: Add cache alignment in sock_common
 for socket lookup fields
Date: Tue, 26 May 2015 11:02:49 -0700
Message-ID: <CALx6S36UhfXaj1L4obo-9pzeyxYZBX7NkmjOfpUWRDWVVx2dqQ@mail.gmail.com>
References: <1432658049-3400132-1-git-send-email-tom@herbertland.com>
	<1432658049-3400132-2-git-send-email-tom@herbertland.com>
	<1432660758.4060.276.camel@edumazet-glaptop2.roam.corp.google.com>
	<1432662883.4060.279.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:33901 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbbEZSCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 14:02:49 -0400
Received: by igbhj9 with SMTP id hj9so66754961igb.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 11:02:49 -0700 (PDT)
In-Reply-To: <1432662883.4060.279.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 10:54 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-05-26 at 10:19 -0700, Eric Dumazet wrote:
>
>> No, we do not want to increase the size of sock_common with such a
>> hammer.
>
> Current sizeof(struct sock_common) is 0x78 bytes.
>
> So moving 2 read_mostly pointers into this structure would be enough to
> make 2 first cache lines read mostly.
>
Right, the problem is refcnt out of those cachelines.

> One candidate would be sk_rx_dst, as it is used in early demux.
>
>
