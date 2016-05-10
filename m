From: Eric Dumazet <edumazet@google.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 14:09:42 -0700
Message-ID: <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	<1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	<90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:36233 "EHLO
	mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbcEJVJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 17:09:43 -0400
Received: by mail-yw0-f178.google.com with SMTP id o66so27562804ywc.3
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 14:09:43 -0700 (PDT)
In-Reply-To: <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 10, 2016 at 1:46 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:

> I agree here, but I don't think this patch particularly is a lot of
> bloat and something very interesting people can play with and extend upon.
>

Sure, very rarely patch authors think their stuff is bloat.

I prefer to fix kernel softirq.c, or at least show me that you tried
hard enough.

I am pretty sure that the following would work :

When ksoftirqd is scheduled, remember this in a per cpu variable
(ksoftiqd_scheduled)

When enabling BH , do not call do_softirq() if this variable is set.

ksoftirqd would clear the variable at the right place (probably in
run_ksoftirqd())

Sure, this might add a lot of latency regressions, but lets fix them.
