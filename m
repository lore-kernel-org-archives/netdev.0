From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire
 X4150(x86) and e1000e
Date: Wed, 30 May 2012 13:08:27 +0200
Message-ID: <1338376107.2760.156.camel@edumazet-glaptop>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	 <88c43001441945e1431609db252b69e7@visp.net.lb>
	 <df211722d18136698aeeda2f17b876e2@visp.net.lb>
	 <d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	 <CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	 <79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	 <CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	 <20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
	 <CA+mtBx_uYy9XcRvpD2E46FuMBFu38iQvCiwFHWqbhPBmY=JfOg@mail.gmail.com>
	 <20120530090602.6204d857.shimoda.hiroaki@gmail.com>
	 <1338367231.2760.125.camel@edumazet-glaptop>
	 <20120530194355.92bf5d51.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	davem@davemloft.net
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59851 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472Ab2E3LIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 07:08:34 -0400
Received: by bkcji2 with SMTP id ji2so3979820bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 04:08:33 -0700 (PDT)
In-Reply-To: <20120530194355.92bf5d51.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 19:43 +0900, Hiroaki SHIMODA wrote:

> While examining ping problem, below pattern is often observed.
> 
>                                                TIME
>        dql_queued()         dql_completed()     |
>       a) initial state                          |
>                                                 |
>       b) X bytes queued                         V
> 
>       c) Y bytes queued
>                            d) X bytes completed
>       e) Z bytes queued
>                            f) Y bytes completed
> 
> a) dql->limit has already some value and there is no in-flight packet.
> b) X bytes queued.
> c) Y bytes queued and excess limit.
> d) X bytes completed and dql->prev_ovlimit is set and also
>    dql->prev_num_queued is set Y.
> e) Z bytes queued.
> f) Y bytes completed. inprogress and prev_inprogress are true.
> 
> At f), if I read the comment correctly, all_prev_completed becomes
> true and limit should be increased. But POSDIFF() ignores
> (A == B) case, so limit is decreased.

Which POSDIFF(), because there are many ;)

By the way, given complexity of this I suggest you split your ideas in
independent patches.

Mabe we should change all POSDIFF(), not selected ones.

#define POSDIFF(A, B) ((int)((A) - (B)) > 0 ? (A) - (B) : 0)
