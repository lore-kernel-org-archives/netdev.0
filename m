From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] [INET]: Get cirtical word in first 64bit of cache
 line
Date: Sun, 02 Dec 2012 09:20:11 -0800
Message-ID: <1354468811.20109.566.camel@edumazet-glaptop>
References: <1353900555-5966-1-git-send-email-ling.ma.program@gmail.com>
	 <1353912241.30446.1257.camel@edumazet-glaptop>
	 <CAOGi=dPQWC8hgt4jhMEHcVPb6j+jMTguNAchiLjdvvHjarCW4Q@mail.gmail.com>
	 <1354024683.7553.1768.camel@edumazet-glaptop>
	 <CAOGi=dO2wZESX5o4Jr_XZu0oPM-Qe30DKt-4f_3TVBrVoR=12Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Ling Ma <ling.ma.program@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOGi=dO2wZESX5o4Jr_XZu0oPM-Qe30DKt-4f_3TVBrVoR=12Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-12-02 at 21:25 +0800, Ling Ma wrote:
> Hi Eric,
> 
> Attached benchmark test-cwf.c(cc -o test-cwf test-cwf.c), the result
> shows when last level cache(LLC) miss and CPU fetches data from
> memory, critical word as first 64bit member in cache line has better
> performance(costs 158290336 cycles ) than other positions(offset 0x10,
> costs 164100732 ) in cache line, the performance is improved by 3.6%
> in this case.
> cpu-info is also involved too.
> 
> Thanks
> Ling

Thanks Ling.

Note that I was more interested by the case we read more fields per
cache line, like we do in tcp lookups. (skc_daddr, skc_rcv_saddr,
skc_bound_dev_if, skc_net).

I made changes to net-next to prepare your patch. 

You'll have to move both skc_rxhash & skc_portpair before the
skc_addrpair.

I have to fix an endianness sparse problem, I'll send a patch for this
in a separate thread right now.
