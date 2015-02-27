From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [patch 1/2] mm: remove GFP_THISNODE
Date: Fri, 27 Feb 2015 23:52:56 +0100
Message-ID: <54F0F548.6070109@suse.cz>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <54EED9A7.5010505@suse.cz> <alpine.DEB.2.10.1502261902580.24302@chino.kir.corp.google.com> <54F01E02.1090007@suse.cz> <alpine.DEB.2.10.1502271335520.4718@chino.kir.corp.google.com> <54F0ED7E.6010900@suse.cz> <alpine.DEB.2.10.1502271428320.7225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Johannes Weiner <hannes@cmpxchg.org>,
 Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>,
 Jarno Rajahalme <jrajahalme@nicira.com>,
 Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, netdev@vger.kernel.org, dev@openvswitch.org
To: David Rientjes <rientjes@google.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <alpine.DEB.2.10.1502271428320.7225@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 27.2.2015 23:31, David Rientjes wrote:
> On Fri, 27 Feb 2015, Vlastimil Babka wrote:
>
>>> Do you see any issues with either patch 1/2 or patch 2/2 besides the
>>> s/GFP_TRANSHUGE/GFP_THISNODE/ that is necessary on the changelog?
>> Well, my point is, what if the node we are explicitly trying to allocate
>> hugepage on, is in fact not allowed by our cpuset? This could happen in the page
>> fault case, no? Although in a weird configuration when process can (and really
>> gets scheduled to run) on a node where it is not allowed to allocate from...
>>
> If the process is running a node that is not allowed by the cpuset, then
> alloc_hugepage_vma() now fails with VM_FAULT_FALLBACK.  That was the
> intended policy change of commit 077fcf116c8c ("mm/thp: allocate
> transparent hugepages on local node").

Ah, right, didn't realize that mempolicy also takes that into account.
Thanks for removing the exception anyway.

>
>   [ alloc_hugepage_vma() should probably be using numa_mem_id() instead for
>     memoryless node platforms. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
