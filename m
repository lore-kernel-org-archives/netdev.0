From: saeed bishara <saeed.bishara@gmail.com>
Subject: Re: [PATCH v2 net-next] inet: Get critical word in first 64bit of
 cache line
Date: Sun, 3 Feb 2013 23:00:30 +0200
Message-ID: <CAMAG_eeeQrvyKizbHb2hkRMV+MiV7u-G+LvSAs3C3NDdGzT4Eg@mail.gmail.com>
References: <1353900555-5966-1-git-send-email-ling.ma.program@gmail.com> <1359817435.30177.70.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ling.ma.program@gmail.com, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:37997 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595Ab3BCVAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 16:00:52 -0500
Received: by mail-la0-f51.google.com with SMTP id fo13so3974614lab.24
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2013 13:00:50 -0800 (PST)
In-Reply-To: <1359817435.30177.70.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 2, 2013 at 5:03 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Ma Ling <ling.ma.program@gmail.com>
>
> In order to reduce memory latency when last level cache miss occurs,
> modern CPUs i.e. x86 and arm introduced Critical Word First(CWF) or
> Early Restart(ER) to get data ASAP. For CWF if critical word is first
> member
> in cache line, memory feed CPU with critical word, then fill others
> data in cache line one by one, otherwise after critical word it must
> cost more cycle to fill the remaining cache line. For Early First CPU
> will restart until critical word in cache line reaches.
>
> Hash value is critical word, so in this patch we place it as first
> member in cache line (sock address is cache-line aligned), and it is
> also good for Early Restart platform as well .
I think the description of this patch doen't make sense. the purpose
of CWF hardware feature is to release the sw from moving critical word
as first member of the cache.
that's ofcourse depends on how you define the CWF, but at least
according to http://lwn.net/Articles/252125/ and here
https://github.com/jamie-allen/cpu_caches/blob/master/preso/presentation.md
the CWF means the hw will do the job.
so I think the patch maybe usefull (1) for system that doesn't have
CWF, (2) CWF may not totaly eliminate the additional latency. this is
of course a prediction as you see.

saeed
