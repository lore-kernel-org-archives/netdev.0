From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/7][MAC8021]: Fix one more call to synchronize_rcu in
 atomic context.
Date: Fri, 16 May 2008 15:05:36 +0400
Message-ID: <482D6A80.6030804@openvz.org>
References: <4821CE54.9000401@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4821CE54.9000401-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi, John. 

Sorry for bothering you, I guess that you're very busy now, 
but what are you plans about this set?

After I saw my first set included in some wireless git update,
I thought this one would be in some of the next ones (since
this set fixes some bugs in mesh tables), and started waiting.

Here's a new wireless git update and this set is still not in.
Shall I resubmit one?

Thanks,
Pavel

> (This set applies OK without the previous one of 4 patches,
>  but with some fuzz in the 7th one)
> 
> 
> The mesh_path_node_free() does so under hashwlock.
> 
> But, this one is called
> 1. from mesh_path_add() after an old hash is hidden and
>    synchronize_rcu() is calld
> 2. mesh_pathtbl_unregister(), when the module is being
>    unloaded and no devices exist to mess with this hash.
> 
> So, it seems to me, that simply removing the call is OK.
> 
> Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> 
> ---
>  net/mac80211/mesh_pathtbl.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
> index 7097ef9..0b6c4bf 100644
> --- a/net/mac80211/mesh_pathtbl.c
> +++ b/net/mac80211/mesh_pathtbl.c
> @@ -458,7 +458,6 @@ static void mesh_path_node_free(struct hlist_node *p, bool free_leafs)
>  	struct mpath_node *node = hlist_entry(p, struct mpath_node, list);
>  	mpath = node->mpath;
>  	hlist_del_rcu(p);
> -	synchronize_rcu();
>  	if (free_leafs)
>  		kfree(mpath);
>  	kfree(node);

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
