From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] tipc: Delete error messages for failed memory
 allocations in three functions
Date: Tue, 23 May 2017 07:02:13 -0700
Message-ID: <1495548133.2093.58.camel@perches.com>
References: <7ac9d513-6f9f-a096-e68f-81a722c2723c@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <7ac9d513-6f9f-a096-e68f-81a722c2723c@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-05-23 at 15:07 +0200, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Tue, 23 May 2017 14:45:25 +0200
> 
> Omit four extra messages for memory allocation failures in these functions.

This is fine but you should look to optimize or figure out
whether optimization is desirable for the effective realloc.

> diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
[]
> @@ -270,11 +268,9 @@ static struct publication *tipc_nameseq_insert_publ(struct net *net,
>  		if (nseq->first_free == nseq->alloc) {
>  			struct sub_seq *sseqs = tipc_subseq_alloc(nseq->alloc * 2);
>  
> -			if (!sseqs) {
> -				pr_warn("Cannot publish {%u,%u,%u}, no memory\n",
> -					type, lower, upper);
> +			if (!sseqs)
>  				return NULL;
> -			}
> +
>  			memcpy(sseqs, nseq->sseqs,
>  			       nseq->alloc * sizeof(struct sub_seq));

tipc_subseq_alloc does a kcalloc (memset to 0),
half of which is immediately overwritten.

In other words, don't just blindly remove stuff,
understand what it does and improve it.

