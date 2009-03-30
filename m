From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Mon, 30 Mar 2009 11:57:57 -0700
Message-ID: <49D11635.2050809@hp.com>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.679540125@vyatta.com>	<499BDB5D.2050105@trash.net> <499C1894.7060400@cosmosbay.com> <49CE568A.9090104@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49CE568A.9090104@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Hi Patrick
> 
> Apparently we could not finish the removal of tcp_lock for 2.6.30 :(
> 
> Stephen suggested using a 4 bytes hole in struct nf_conntrack,
> but this is ok only if sizeof(spinlock_t) <= 4 and 64 bit arches.
> 
> We could do an hybrid thing : use nf_conn.ct_general.lock if 64 bit arches
> and sizeof(spinlock_t) <= 4.
> 
> Other cases would use a carefuly sized array of spinlocks...
> 
> Thank you
> 
> [PATCH] netfilter: finer grained nf_conn locking
> 
> Introduction of fine grained lock infrastructure for nf_conn.
> If possible, we use a 32bit hole on 64bit arches.
> Else we use a global array of hashed spinlocks, so we dont
> change size of "struct nf_conn"
> 
> Get rid of central tcp_lock rwlock used in TCP conntracking
> using this infrastructure for better performance on SMP.
> 
> "tbench 8" results on my 8 core machine (32bit kernel, with
> conntracking on) : 2319 MB/s instead of 2284 MB/s

Is this an implicit request for me to try to resurrect the 32-core setup?

rick jones
