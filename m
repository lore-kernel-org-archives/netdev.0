From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ax25.h unsigned long type for ax25 timers
Date: Tue, 17 Jun 2008 22:30:50 -0700 (PDT)
Message-ID: <20080617.223050.266166325.davem@davemloft.net>
References: <200806171504.38702.bpidoux@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org
To: bpidoux@free.fr
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <200806171504.38702.bpidoux@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernard Pidoux <bpidoux@free.fr>
Date: Tue, 17 Jun 2008 15:04:38 +0200

> In linux/include/linux/ax25.h
> ax25_info_struct timers types remain unsigned
> 
> struct ax25_info_struct {
> 	unsigned int	n2, n2count;
> 	unsigned int	t1, t1timer;
> 	unsigned int	t2, t2timer;
> 	unsigned int	t3, t3timer;
> 	unsigned int	idle, idletimer;
>         .....
> };
> 
> while in linux/include/net/ax25.h timers are unsigned long according
> to kernel 2.6 timers.
> 
> typedef struct ax25_cb {
>         .....
>         struct timer_list       t1timer, t2timer, t3timer, idletimer;
>         unsigned long           t1, t2, t3, idle, rtt;
>         ....
> 
> Although ax25_info_struct is not much used it is refered at least
> into libax25 and xfbb BBS application program.
> 
> It seems thus reasonable to make the change.
> 
> Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>

Unfortunately this datastructure is exported to userspace,
and therefore we cannot change the structure layout without
breaking userspace.

We cannot, as a result, make this change.

The only way to fix this is to make a new fixed structure, and add new
ax25 calls that accept this new structure.
