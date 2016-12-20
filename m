From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2 v2] mm, slab: consolidate KMALLOC_MAX_SIZE
Date: Tue, 20 Dec 2016 14:06:57 +0100
Message-ID: <20161220130659.16461-1-mhocko@kernel.org>
Cc: Cristopher Lameter <cl@linux.com>,
	Alexei Starovoitov <ast@kernel.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	netdev@vger.kernel.org,
	<linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hi,
this is the second version of the patchset previously posted here [1].
Alexei has insisted on the patches reordering which I've done in this
series. I've also updated the changelog of the second patch to mention
why KMALLOC_SHIFT_MAX has been used.

Andrey has revealed a discrepancy between KMALLOC_MAX_SIZE and the
maximum supported page allocator size [2]. The underlying problem
should be fixed in the ep_write_iter code of course, but I do not feel
qualified to do that. The discrepancy which it reveals (see patch 2)
is worth fixing anyway, though.

While I was looking into the code, I've noticed that the only code which
uses KMALLOC_SHIFT_MAX outside of the slab code is bpf so I've updated
it to use KMALLOC_MAX_SIZE instead. There shouldn't be any real reason
to use KMALLOC_SHIFT_MAX which is a slab internal constant same as
KMALLOC_SHIFT_{LOW,HIGH}

[1] http://lkml.kernel.org/r/20161215164722.21586-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/CAAeHK+ztusS68DejO8AH3nn-EfiYQpD5FmBwmqKG8BWvoqPNqQ@mail.gm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
