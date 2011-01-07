From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid
 not used
Date: Thu, 6 Jan 2011 18:29:12 -0800
Message-ID: <20110107022912.GA17757@mcarlson.broadcom.com>
References: <AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
 <20101213224510.GB17400@mcarlson.broadcom.com>
 <AANLkTi=9BYt=vkNkAiTBxnfnCjCX7AqCG=ML6coc4vdZ@mail.gmail.com>
 <20101214191500.GD19951@mcarlson.broadcom.com>
 <1293901393.2535.49.camel@edumazet-laptop>
 <AANLkTinq9ABi0prxe0m1Ma6rno4UnAOzuW-b5L362ij9@mail.gmail.com>
 <1293984348.2535.101.camel@edumazet-laptop>
 <AANLkTincX-wPQE9gs16v53E4=Skivzc4ZSJS43oNBLD_@mail.gmail.com>
 <1294356887.2704.13.camel@edumazet-laptop>
 <1294363201.2704.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Jesse Gross" <jesse@nicira.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Leun" <lkml20101129@newton.leun.net>,
	"Michael Chan" <mchan@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	"Ben Greear" <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294363201.2704.19.camel@edumazet-laptop>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 06, 2011 at 05:20:01PM -0800, Eric Dumazet wrote:
> Le vendredi 07 janvier 2011 ?? 00:34 +0100, Eric Dumazet a ??crit :
> > Le jeudi 06 janvier 2011 ?? 16:01 -0500, Jesse Gross a ??crit :
> > 
> > > Hmm, I thought that it might be some interaction with a corner case in
> > > the networking core but now it seems less likely.  There weren't too
> > > many vlan changes between the working and non-working states.  Plus,
> > > since the rx counter isn't increasing, the packets probably aren't
> > > making it anywhere.
> > > 
> > > I see that tg3 increases the drop counter in one place, which also
> > > happens to be checking for vlan errors (at tg3.c:4753).  That seems
> > > suspicious - maybe the NIC is only partially configured for vlan
> > > offloading.  If we can confirm that is where the drop counter is being
> > > incremented and what the error code is maybe it would shed some light.
> > > 
> > 
> > Hmm... I am pretty sure the drop counter is the dev rx_dropped (core
> > network handled, not tg3 one) incremented at the end of
> > __netif_receive_skb() : We found no suitable handler for packets.
> > 
> > atomic_long_inc(&skb->dev->rx_dropped);
> > 
> > But thats a guess, I'll have to check
> > 
> 
> wrong guess. Its really the tg3 which drops frames
> 
> increasing rx_missed_errors  (get_stat64(&hw_stats->rx_discards)
> 
> ip -s -s link show dev eth2
> 5: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq
> master bond0 state UP qlen 1000
>     link/ether 00:1e:0b:92:78:50 brd ff:ff:ff:ff:ff:ff
>     RX: bytes  packets  errors  dropped overrun mcast   
>     11627      167      0       0       0       2      
>     RX errors: length  crc     frame   fifo    missed
>                0        0       0       0       2713   
>     TX: bytes  packets  errors  dropped carrier collsns 
>     2274       31       0       0       0       0      
>     TX errors: aborted fifo    window  heartbeat
>                0        0       0       0      
> 
> 
> 
> It would be nice Broadcom guys could help a bit ?

Hi Eric.  Sorry for the delay.  I was under the impression that your
problems were software related and that you just needed a revised
version of these VLAN patches I was sending to Michael.  Is this not
true?

Having a hardware stat increment suggests this is a new problem.
Maybe I missed it, but I didn't see what hardware you are working
with and whether or not management firmware was enabled.  Could you tell
me that info?
