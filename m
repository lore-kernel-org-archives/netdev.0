From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading
 /proc/net/dev.
Date: Tue, 5 Oct 2010 23:16:37 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1010052313370.30765@ask.diku.dk>
References: <20101005141833.20929.10943.stgit@localhost>
 <1286289703.2796.292.camel@edumazet-laptop>  <1286290393.7071.38.camel@firesoul.comx.local>
  <1286291947.2796.387.camel@edumazet-laptop> <1286312479.2593.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-309378348-1286313397=:30765"
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:50442 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755351Ab0JEVQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 17:16:40 -0400
In-Reply-To: <1286312479.2593.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-309378348-1286313397=:30765
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

On Tue, 5 Oct 2010, Eric Dumazet wrote:

> Le mardi 05 octobre 2010 à 17:19 +0200, Eric Dumazet a écrit :
>> Le mardi 05 octobre 2010 à 16:53 +0200, Jesper Dangaard Brouer a écrit :
>>
>>> Its already racy, because "ethtool -S" reads out the stats immediately,
>>> and thus races with the timer.
>>>
>>> See: igb_ethtool.c
>>>  igb_get_ethtool_stats() invoke igb_update_stats(adapter);
>>>
>>
>> You would be surprised how many bugs are waiting to be found and
>> fixed ;)
>
> I took a look at igb stats, and it appears they also are racy on 32bit
> arches. igb uses u64 counters, with no synchronization between
> producers(writers) and consumers(readers).

Are you saying, that we need more than a simple mutex in 
igb_update_stats()?


> Some fixes are needed ;)

The question is then if Intel wants to fix it, or let it be up to you or 
me?

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
---511516320-309378348-1286313397=:30765--
