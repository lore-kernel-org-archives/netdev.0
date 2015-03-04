From: Mel Gorman <mgorman@suse.de>
Subject: Re: SOCK_MEMALLOC vs loopback
Date: Wed, 4 Mar 2015 20:04:27 +0000
Message-ID: <20150304200427.GQ3087@suse.de>
References: <CAOi1vP8tJTMhbCyKVD66pc_Tz7+aOS236KgvQnA-S63yv1P-sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: ceph-devel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Sage Weil <sage@redhat.com>,
	Mike Christie <mchristi@redhat.com>, NeilBrown <neilb@suse.de>,
	netdev@vger.kernel.org
To: Ilya Dryomov <idryomov@gmail.com>
Return-path: <ceph-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOi1vP8tJTMhbCyKVD66pc_Tz7+aOS236KgvQnA-S63yv1P-sA@mail.gmail.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 04, 2015 at 09:38:48PM +0300, Ilya Dryomov wrote:
> Hello,
> 
> A short while ago Mike added a patch to libceph to set SOCK_MEMALLOC on
> libceph sockets and PF_MEMALLOC around send/receive paths (commit
> 89baaa570ab0, "libceph: use memalloc flags for net IO").  rbd is much
> like nbd and is succeptible to all the same memory allocation
> deadlocks, so it seemed like a step in the right direction.
> 

The contract for SOCK_MEMALLOC is that it would only be used for temporary
allocations that were necessary for the system to make forward progress. In
the case of swap-over-NFS, it would only be used for transmitting
buffers that were necessary to write data to swap when there were no
other options. If that contract is not met then using it can deadlock the
system. It's the same for PF_MEMALLOC -- activating that is a recipe for
deadlock due to memory exhaustion.

-- 
Mel Gorman
SUSE Labs
