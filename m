From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
Date: Thu, 12 Jan 2017 15:14:54 -0500
Message-ID: <09bbc480-1490-da27-732c-046e0ebfa89f@oracle.com>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>,
        Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org,
        LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Anton Vorontsov
 <anton@enomsg.org>, Colin Cross <ccross@android.com>,
        Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Ben Skeggs <bskeggs@redhat.com>,
        Kent Overstreet <kent.overstreet@gmail.com>,
        Santosh Raspatur <santosh@chelsio.com>,
        Hariprasad S
 <hariprasad@chelsio.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Yishai
To: Michal Hocko <mhocko@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20170112153717.28943-6-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


> diff --git a/drivers/xen/evtchn.c b/drivers/xen/evtchn.c
> index 6890897a6f30..10f1ef582659 100644
> --- a/drivers/xen/evtchn.c
> +++ b/drivers/xen/evtchn.c
> @@ -87,18 +87,6 @@ struct user_evtchn {
>  	bool enabled;
>  };
> =20
> -static evtchn_port_t *evtchn_alloc_ring(unsigned int size)
> -{
> -	evtchn_port_t *ring;
> -	size_t s =3D size * sizeof(*ring);
> -
> -	ring =3D kmalloc(s, GFP_KERNEL);
> -	if (!ring)
> -		ring =3D vmalloc(s);
> -
> -	return ring;
> -}
> -
>  static void evtchn_free_ring(evtchn_port_t *ring)
>  {
>  	kvfree(ring);
> @@ -334,7 +322,7 @@ static int evtchn_resize_ring(struct per_user_data =
*u)
>  	else
>  		new_size =3D 2 * u->ring_size;
> =20
> -	new_ring =3D evtchn_alloc_ring(new_size);
> +	new_ring =3D kvmalloc(new_size * sizeof(*new_ring), GFP_KERNEL);
>  	if (!new_ring)
>  		return -ENOMEM;
> =20

Xen bits:

Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
