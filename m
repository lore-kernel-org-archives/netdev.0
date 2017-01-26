From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Date: Thu, 26 Jan 2017 04:14:37 -0800
Message-ID: <1485432877.12563.100.camel@perches.com>
References: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
         <588907AA.1020704@iogearbox.net> <20170126074354.GB8456@dhcp22.suse.cz>
         <5889C331.7020101@iogearbox.net> <20170126100802.GF6590@dhcp22.suse.cz>
         <20170126103216.GG6590@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>,
        Johannes Weiner <hannes@cmpxchg.org>,
        linux-mm <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        marcelo.leitner@gmail.com
To: Michal Hocko <mhocko@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170126103216.GG6590@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-01-26 at 11:32 +0100, Michal Hocko wrote:
> So I have folded the following to the patch 1. It is in line with
> kvmalloc and hopefully at least tell more than the current code.
[]
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
[]
> @@ -1741,6 +1741,13 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>   *	Allocate enough pages to cover @size from the page level
>   *	allocator with @gfp_mask flags.  Map them into contiguous
>   *	kernel virtual space, using a pagetable protection of @prot.
> + *
> + *	Reclaim modifiers in @gfp_mask - __GFP_NORETRY, __GFP_REPEAT
> + *	and __GFP_NOFAIL are not supported

Maybe add a BUILD_BUG or a WARN_ON_ONCE to catch new occurrences?
