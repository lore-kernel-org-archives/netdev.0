From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Is kernel 2.6.11 adjust tcp_max_syn_backlog incorrectly?
Date: Mon, 13 Jun 2005 14:24:18 -0700 (PDT)
Message-ID: <20050613.142418.08323454.davem@davemloft.net>
References: <75052be7050606070691c302d@mail.gmail.com>
	<75052be705060607106a6c0882@mail.gmail.com>
	<m11x79dwcb.fsf@muc.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gnuwind@gmail.com, casavan@sgi.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261410AbVFMVZu@vger.kernel.org>
To: ak@muc.de
In-Reply-To: <m11x79dwcb.fsf@muc.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@muc.de>
Date: Sat, 11 Jun 2005 12:25:08 +0200

> Yes, there were some changes here when it was converted to a common
> function for all hash tables (alloc_large_system_hash - the function
> with the argument list from hell).  Anyways, here's a quick fix.
> 
> DaveM for your consideration.
> 
> Adjust TCP mem order check to new alloc_large_system_hash
> 
> Signed-off-by: Andi Kleen <ak@suse.de>

I just reread those NUMA changes, and they changed the heuristics
for sizing things at the same time as moving over to the
alloc_large_system_hash() change.

The change was to move from (21 - PAGE_SHIFT) and (23 - PAGE_SHIFT)
to (25 - PAGE_SHIFT) and (27 - PAGE_SHIFT) respectively.

This is the part of the NUMA TCP changes that made the sysctl setting
behavior differ.

Andi's patch is the least intrusive fix for 2.6.12, so I will
apply it.  But longer term these heuristics need to be revisited
as a whole.
