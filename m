From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [RFC PATCH v2 net-next 1/3] tcp: replace cnt & rtt with struct in pkts_acked()
Date: Wed, 22 Jul 2015 07:04:58 -0400
Message-ID: <CADVnQyk8CsHBi3mLR+DGO5wX5xz++HHfC1GfkZ4T7bRmyvy3dQ@mail.gmail.com>
References: <1437538896-1330704-1-git-send-email-brakmo@fb.com>
	<1437538896-1330704-2-git-send-email-brakmo@fb.com>
	<1437544010.16824.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:36809 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933446AbbGVLE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 07:04:59 -0400
Received: by oibn4 with SMTP id n4so141354799oib.3
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 04:04:58 -0700 (PDT)
In-Reply-To: <1437544010.16824.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 22, 2015 at 1:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-07-21 at 21:21 -0700, Lawrence Brakmo wrote:
>> Replace 2 arguments (cnt and rtt) in the congestion control modules'
>> pkts_acked() function with a struct. This will allow adding more
>> information without having to modify existing congestion control
>> modules (tcp_nv in particular needs bytes in flight when packet
>> was sent).
>>
>> This was proposed by Neal Cardwell in his comments to the tcp_nv patch.
>
> Are you sure Neal suggested to pass a struct as argument ?
>
> It was probably a struct pointer instead.

Yes, I may not have specified, but I definitely agree we should pass
the struct by pointer, as the intent is that the struct may grow over
time, and we don't want to pay more overhead to copy the struct for
the call.

neal
