From: Chetan Loke <chetanloke@gmail.com>
Subject: Re: [Pv-drivers] rps and pvdrivers
Date: Sat, 4 Sep 2010 10:02:36 -0400
Message-ID: <AANLkTik+T8Sv1tEmy4PU0O-dOeymJLEkEd9QOYy7ZJzC@mail.gmail.com>
References: <AANLkTimrHh1ZasO=GWUOT9YJbu2EqeAx6OkRXPUSSNJ6@mail.gmail.com>
	<8B1F619C9F5F454E81D90D3C161698D70337A49A5A@EXCH-MBX-3.vmware.com>
	<AANLkTi=o8GYdLyY8EzfRno39O2kUSh3wSp9raZCUp_Zz@mail.gmail.com>
	<1283583095.2320.11.camel@edumazet-laptop>
	<AANLkTimC4z7mCKwyK8=LaacjTtZGEGN_BYsFMydQiwBk@mail.gmail.com>
	<1283608311.3402.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bhavesh Davda <bhavesh@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"therbert@google.com" <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43005 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940Ab0IDOCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 10:02:38 -0400
Received: by fxm13 with SMTP id 13so1797784fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Sep 2010 07:02:37 -0700 (PDT)
In-Reply-To: <1283608311.3402.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 4, 2010 at 9:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> If packets have same rxhash, (same src IP, dst IP, src port, dst port),
> they are directed on a single CPU, and this might explain you cannot
> handle the load, RPS or not.

I tried incrementing the src-macs from the load-generator. Or only the
above 4-tuple entries are used?


>
> cat /proc/net/softnet_stat
>

cat /proc/net/softnet_stat
0655cb87 006dd31b 00096a78 00000000 00000000 00000000 00000000
00000000 00000000 00000dbe
0042feec 00000000 0008ae33 00000000 00000000 00000000 00000000
00000000 00000000 00000000

cat /proc/net/softnet_stat
065d444e 006e669d 00097565 00000000 00000000 00000000 00000000
00000000 00000000 00000dbe
0042ff8c 00000000 0008b83f 00000000 00000000 00000000 00000000
00000000 00000000 00000000

cat /proc/net/softnet_stat
066a6fcf 006fefd9 000988c9 00000000 00000000 00000000 00000000
00000000 00000000 00000dbe
004300bd 00000000 0008c945 00000000 00000000 00000000 00000000
00000000 00000000 00000000



> RPS is good to handle multiple flows, because it can distribute load on
> several cpus. But with a single flow, I guess it might be not that
> useful.

For single flow if it doesn't improve performance that's fine. But it
should atleast work as good as N-2(2.6.33).


Chetan Loke
