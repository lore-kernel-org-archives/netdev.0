From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 28 Apr 2008 19:20:47 -0700
Message-ID: <d1c2719f0804281920l29343116s5271191eb6584323@mail.gmail.com>
References: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
	 <1e41a3230804240932u510609beh8fb577baaadeb9bd@mail.gmail.com>
	 <d1c2719f0804241749p2c0dd7daofd343bc37a916247@mail.gmail.com>
	 <20080424.234628.170849475.davem@davemloft.net>
	 <d1c2719f0804281130n7b0aaab8t54b2a585cff53a99@mail.gmail.com>
	 <1e41a3230804281221s11442a82j55c363116988a5cb@mail.gmail.com>
	 <d1c2719f0804281338j3984cf2bga31def0c2c1192a1@mail.gmail.com>
	 <1e41a3230804281628r363f9d3cn7b0eee0bd6423e65@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	rick.jones2@hp.com
To: "John Heffner" <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:35369 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbYD2CUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 22:20:52 -0400
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m3T2KnJ2008993
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 03:20:49 +0100
Received: from hs-out-0708.google.com (hsc55.prod.google.com [10.44.3.55])
	by zps37.corp.google.com with ESMTP id m3T2KmI7004868
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 19:20:48 -0700
Received: by hs-out-0708.google.com with SMTP id 55so3999802hsc.10
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 19:20:48 -0700 (PDT)
In-Reply-To: <1e41a3230804281628r363f9d3cn7b0eee0bd6423e65@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just for the record, in my netperf RR (1MB request/20B reply) over
1GE/tg3 test on top of 2.6.18, changing tcp_tso_win_divisor to 0
from the default of 3 gets the cwnd down to 695 from 1037. Applying
the bound check (left * tp->mss_cache < 65536) will get cwnd down
to 737, not 695. Still big improvement though. (Anyway this may be
moot after I fix the real culprit.)

Jerry

On Mon, Apr 28, 2008 at 4:28 PM, John Heffner <johnwheffner@gmail.com> wrote:
>
> On Mon, Apr 28, 2008 at 1:38 PM, Jerry Chu <hkchu@google.com> wrote:
> > > Try this series of patches, against net-next.
> >
> > Ah, you already know about this problem. Yes it does the trick.
>
> I had not actually known about this.  (Just cooked up the patches
> after I saw your mail.)  This looks to me like a clear bug.  After
> looking carefully at the code there, it seems there was another small
> problem, too, though not likely to have much effect.
>
> Dave, can you apply the patches I just sent?
>
> Thanks,
>  -John
>
