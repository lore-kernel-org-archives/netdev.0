From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] netfilter: iptables no lockdep is needed..
Date: Sun, 26 Apr 2009 10:18:25 +0200
Message-ID: <20090426081825.GA2755@ami.dom.local>
References: <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain> <20090421111541.228e977a@nehalam> <20090421193924.GA24404@elte.hu> <20090421143927.52d7d89d@nehalam> <alpine.LFD.2.00.0904220821240.3101@localhost.localdomain> <20090423210938.1501507b@nehalam> <49F146FF.5050200@cosmosbay.com> <20090424091839.6e13ebec@nehalam> <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Paul Mackerras <paulus@samba.org>,
	paulmck@linux.vnet.ibm.com, Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754736AbZDZITd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090425133052.4cb711f5@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 25, 2009 at 01:30:52PM -0700, Stephen Hemminger wrote:
> Epilogue due to master Jarek. Lockdep carest not about the locking
> doth bestowed. Therefore no keys are needed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Very nice! I guess this Shakespeare guy Will sign off this all too. ;-)

Thanks,
Jarek P.

> 
> ---
>  net/netfilter/x_tables.c |    9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)
> 
> --- a/net/netfilter/x_tables.c	2009-04-25 13:25:48.115026283 -0700
> +++ b/net/netfilter/x_tables.c	2009-04-25 13:26:15.646215635 -0700
> @@ -1145,14 +1145,9 @@ static int __init xt_init(void)
>  {
>  	unsigned int i;
>  	int rv;
> -	static struct lock_class_key xt_lock_key[NR_CPUS];
>  
> -	for_each_possible_cpu(i) {
> -		rwlock_t *lock = &per_cpu(xt_info_locks, i);
> -
> -		rwlock_init(lock);
> -		lockdep_set_class(lock, xt_lock_key+i);
> -	}
> +	for_each_possible_cpu(i)
> +		rwlock_init(&per_cpu(xt_info_locks, i));
>  
>  	xt = kmalloc(sizeof(struct xt_af) * NFPROTO_NUMPROTO, GFP_KERNEL);
>  	if (!xt)
