From: David Miller <davem@davemloft.net>
Subject: Re: Null pointer dereference in nf_nat_move_storage(), kernel
 2.6.23.1
Date: Thu, 15 Nov 2007 15:55:09 -0800 (PST)
Message-ID: <20071115.155509.107545186.davem@davemloft.net>
References: <473B3874.2020104@redhat.com>
	<473B83DB.5040303@redhat.com>
	<20071115120658.GA17667@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cebbert@redhat.com, netfilter-devel@vger.kernel.org,
	kaber@trash.net, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20071115120658.GA17667@2ka.mipt.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 15 Nov 2007 15:06:59 +0300

> Please test attached patch.
> 
> This routing is called each time hash should be replaced, nf_conn has
> extension list which contains pointers to connection tracking users
> (like nat, which is right now the only such user), so when replace takes
> place it should copy own extensions. Loop above checks for own
> extension, but tries to move higer-layer one, which can lead to above
> oops.
> 
> Not tested, derived from code observation only.
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

It looks extremely correct to me.  Therefore I'm going to apply
this and queue it up for -stable.

Thanks Evgeniy, keep up the excellent work!

Patrick, please let me know if you have any objections.

> diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
> index a1a65a1..cf6ba66 100644
> --- a/net/netfilter/nf_conntrack_extend.c
> +++ b/net/netfilter/nf_conntrack_extend.c
> @@ -109,7 +109,7 @@ void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
>  			rcu_read_lock();
>  			t = rcu_dereference(nf_ct_ext_types[i]);
>  			if (t && t->move)
> -				t->move(ct, ct->ext + ct->ext->offset[id]);
> +				t->move(ct, ct->ext + ct->ext->offset[i]);
>  			rcu_read_unlock();
>  		}
>  		kfree(ct->ext);
> 
