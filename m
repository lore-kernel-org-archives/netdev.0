From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH 5/9] treewide: use kv[mz]alloc* rather than opencoded
 variants
Date: Mon, 30 Jan 2017 17:14:21 +0100
Message-ID: <9793f9d3-4ef1-aad0-b38f-d8760e536ff9@suse.cz>
References: <20170130094940.13546-1-mhocko@kernel.org>
 <20170130094940.13546-6-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>,
 Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>,
 linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>,
 Michal Hocko <mhocko@suse.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov
 <anton@enomsg.org>, Colin Cross <ccross@android.com>,
 Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>,
 Kent Overstreet <kent.overstreet@gmail.com>,
 Santosh Raspatur <santosh@chelsio.com>, Hariprasad S
 <hariprasad@chelsio.com>, Yishai Hadas <yishaih@mellanox.com>,
 Oleg Drokin <oleg.drokin@intel.com>, "Yan, Zheng" <zyan@redhat.com>,
 Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
 net
To: Michal Hocko <mhocko@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20170130094940.13546-6-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 01/30/2017 10:49 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> There are many code paths opencoding kvmalloc. Let's use the helper
> instead. The main difference to kvmalloc is that those users are usually
> not considering all the aspects of the memory allocator. E.g. allocation
> requests <= 32kB (with 4kB pages) are basically never failing and invoke
> OOM killer to satisfy the allocation. This sounds too disruptive for
> something that has a reasonable fallback - the vmalloc. On the other
> hand those requests might fallback to vmalloc even when the memory
> allocator would succeed after several more reclaim/compaction attempts
> previously. There is no guarantee something like that happens though.
>
> This patch converts many of those places to kv[mz]alloc* helpers because
> they are more conservative.
>
> Changes since v1
> - add kvmalloc_array - this might silently fix some overflow issues
>   because most users simply didn't check the overflow for the vmalloc
>   fallback.
>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Anton Vorontsov <anton@enomsg.org>
> Cc: Colin Cross <ccross@android.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Ben Skeggs <bskeggs@redhat.com>
> Cc: Kent Overstreet <kent.overstreet@gmail.com>
> Cc: Santosh Raspatur <santosh@chelsio.com>
> Cc: Hariprasad S <hariprasad@chelsio.com>
> Cc: Yishai Hadas <yishaih@mellanox.com>
> Cc: Oleg Drokin <oleg.drokin@intel.com>
> Cc: "Yan, Zheng" <zyan@redhat.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: netdev@vger.kernel.org
> Acked-by: Andreas Dilger <andreas.dilger@intel.com> # Lustre
> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com> # Xen bits
> Acked-by: Christian Borntraeger <borntraeger@de.ibm.com> # KVM/s390
> Acked-by: Dan Williams <dan.j.williams@intel.com> # nvdim
> Acked-by: David Sterba <dsterba@suse.com> # btrfs
> Acked-by: Ilya Dryomov <idryomov@gmail.com> # Ceph
> Acked-by: Tariq Toukan <tariqt@mellanox.com> # mlx4
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
