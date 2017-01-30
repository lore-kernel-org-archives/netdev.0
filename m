From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH 5/9] treewide: use kv[mz]alloc* rather than opencoded variants
Date: Mon, 30 Jan 2017 11:24:02 -0800
Message-ID: <CAGXu5jLFwQuUyZuRuK60YBGYbbEkt+C3dKxCyDe65Ad5co2oLw@mail.gmail.com>
References: <20170130094940.13546-1-mhocko@kernel.org> <20170130094940.13546-6-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>,
	David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>,
	Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>,
	Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Tony Luck <tony.luck@intel.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>,
	Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>, Yishai Hadas <yishaih@mellanox.com>,
	Oleg Drokin <oleg.drokin@intel.com>, "Yan, Zheng" <zyan@redhat.com>,
	Alexei Starovoitov
To: Michal Hocko <mhocko@kernel.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20170130094940.13546-6-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 30, 2017 at 1:49 AM, Michal Hocko <mhocko@kernel.org> wrote:
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

Awesome, thanks for adding that API. :)

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
