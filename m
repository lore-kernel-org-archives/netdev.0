From: =?UTF-8?B?U3JlxIdrbyBKdXJpxIctS2F2ZWxq?=
	<srecko.juric-kavelj@fer.hr>
Subject: Re: Using jiffies for tcp_time_stamp?
Date: Fri, 25 May 2012 18:23:40 +0200
Message-ID: <CAACrLC0b5dyjJM=DGf-9nUOwar3O9EVTTR0tvynQj285EDpfwA@mail.gmail.com>
References: <CAACrLC39Xdm3vTKUsjz43ZPyEq_vHxR-_Uf56SjSm+kUqxOqZg@mail.gmail.com>
	<CAACrLC2CXU-DNeonWQGJTfX53ssm_asK7WQrFuWRBB77cg-YdA@mail.gmail.com>
	<4FBFAC30.8050508@genband.com>
	<CAA93jw7MU8PjFk-UX864STSBp2SjjjivmfpRiPhaQ2kxZLu2sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chris Friesen <chris.friesen@genband.com>, netdev@vger.kernel.org
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:39050 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756114Ab2EYQXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 12:23:41 -0400
Received: by yenm10 with SMTP id m10so488033yen.19
        for <netdev@vger.kernel.org>; Fri, 25 May 2012 09:23:41 -0700 (PDT)
In-Reply-To: <CAA93jw7MU8PjFk-UX864STSBp2SjjjivmfpRiPhaQ2kxZLu2sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 25, 2012 at 6:17 PM, Dave Taht <dave.taht@gmail.com> wrote:
> On Fri, May 25, 2012 at 4:58 PM, Chris Friesen
> <chris.friesen@genband.com> wrote:
>> I don't know if it would make any difference to the tcp algorithms, but
>> certainly on some architectures you can get a fast and accurate hardware
>> timestamp.
>
> I would be interested in someone doing that experiment in light of the
> codel work.

I've looked this up in other implementations, e.g. FreeBSD uses 1ms
granularity no matter what HZ says, NetBSD has 500ms ticks, ...

I guess that granularity also depends on the retransmit timers used. I
didn't make out what's the precision of the timers that Linux uses in
TCP, but I guess it uses high resolution timers? At least on x86?

I've done a simple experiment by repeatedly calling clock_gettime
(from userspace, but I guess it ends up as a vsyscall). I get >17
million calls per second on a Q6600.

--
JKS
