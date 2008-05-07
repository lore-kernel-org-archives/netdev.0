From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 7/7][MAC80211]: Consolidate hash kfree-ing in mesh.c.
Date: Wed, 7 May 2008 18:03:10 +0200
Message-ID: <200805071803.11291.mb@bu3sch.de>
References: <4821D157.90403@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4821D157.90403-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 07 May 2008 17:57:11 Pavel Emelyanov wrote:
> There are already two places, that kfree the mesh_table and
> its buckets.
> 
> Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> 
> ---
>  net/mac80211/mesh.c |   15 +++++++++------
>  1 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
> index f46fbdb..876ec18 100644
> --- a/net/mac80211/mesh.c
> +++ b/net/mac80211/mesh.c
> @@ -315,6 +315,13 @@ struct mesh_table *mesh_table_alloc(int size_order)
>  	return newtbl;
>  }
>  
> +static void __mesh_table_free(struct mesh_table *tbl)

Why is this __double_underscored?

> +{
> +	kfree(tbl->hash_buckets);
> +	kfree(tbl->hashwlock);
> +	kfree(tbl);
> +}
> +
>  void mesh_table_free(struct mesh_table *tbl, bool free_leafs)
>  {
>  	struct hlist_head *mesh_hash;
> @@ -330,9 +337,7 @@ void mesh_table_free(struct mesh_table *tbl, bool free_leafs)
>  		}
>  		spin_unlock(&tbl->hashwlock[i]);
>  	}
> -	kfree(tbl->hash_buckets);
> -	kfree(tbl->hashwlock);
> -	kfree(tbl);
> +	__mesh_table_free(tbl);
>  }
>  
>  static void ieee80211_mesh_path_timer(unsigned long data)
> @@ -378,9 +383,7 @@ errcopy:
>  		hlist_for_each_safe(p, q, &newtbl->hash_buckets[i])
>  			tbl->free_node(p, 0);
>  	}
> -	kfree(newtbl->hash_buckets);
> -	kfree(newtbl->hashwlock);
> -	kfree(newtbl);
> +	__mesh_table_free(tbl);
>  endgrow:
>  	return NULL;
>  }



-- 
Greetings Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
