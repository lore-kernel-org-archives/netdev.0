From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
Date: Mon, 16 Jan 2017 08:33:11 +0100
Message-ID: <20170116073310.GA7981@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
 <20170114105632.GV20392@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>,
        David Rientjes <rientjes@google.com>,
        Mel Gorman <mgorman@suse.de>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org,
        LKML <linux-kernel@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Anton Vorontsov <anton@enomsg.org>,
        Colin Cross <ccross@android.com>,
        Kees Cook <keescook@chromium.org>,
        Tony Luck <tony.luck@intel.com>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Ben Skeggs <bskeggs@redhat.com>,
        Kent Overstreet <kent.overstreet@gmail.com>,
        Santosh Raspatur <santosh@chelsio.com>,
        Hariprasad S <hariprasad@chelsio.com>,
        Ta
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170114105632.GV20392@mtr-leonro.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat 14-01-17 12:56:32, Leon Romanovsky wrote:
[...]
> Hi Michal,
> 
> I don't see mlx5_vzalloc in the changed list. Any reason why did you skip it?
> 
>  881 static inline void *mlx5_vzalloc(unsigned long size)
>  882 {
>  883         void *rtn;
>  884
>  885         rtn = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
>  886         if (!rtn)
>  887                 rtn = vzalloc(size);
>  888         return rtn;
>  889 }

No reason to skip it, I just didn't see it. I will fold the following in
if you are OK with it
---
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index cdd2bd62f86d..5e6063170e48 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -874,12 +874,7 @@ static inline u16 cmdif_rev(struct mlx5_core_dev *dev)
 
 static inline void *mlx5_vzalloc(unsigned long size)
 {
-	void *rtn;
-
-	rtn = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
-	if (!rtn)
-		rtn = vzalloc(size);
-	return rtn;
+	return kvzalloc(GFP_KERNEL, size);
 }
 
 static inline u32 mlx5_base_mkey(const u32 key)

-- 
Michal Hocko
SUSE Labs
