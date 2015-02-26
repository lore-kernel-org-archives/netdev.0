From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm: remove GFP_THISNODE
Date: Wed, 25 Feb 2015 17:04:56 -0800 (PST)
Message-ID: <alpine.DEB.2.10.1502251701340.12985@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.11.1502251855330.14795@gentwo.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
    Vlastimil Babka <vbabka@suse.cz>, Pekka Enberg <penberg@kernel.org>,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>,
    Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>,
    Jarno Rajahalme <jrajahalme@nicira.com>, Greg Thelen <gthelen@google.com>,
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org,
    dev@openvswitch.org
To: Christoph Lameter <cl@linux.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <alpine.DEB.2.11.1502251855330.14795@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Feb 2015, Christoph Lameter wrote:

> On Wed, 25 Feb 2015, David Rientjes wrote:
> 
> > NOTE: this is not about __GFP_THISNODE, this is only about GFP_THISNODE.
> 
> Well but then its not removing it. You are replacing it with an inline
> function.
> 

Removing GFP_THISNODE, not __GFP_THISNODE.  GFP_THISNODE, as the commit 
message says, is a special collection of flags that means "never try 
reclaim" and people confuse it for __GFP_THISNODE.

There are legitimate usecases where we want __GFP_THISNODE, in other words 
restricting the allocation to only a specific node, and try reclaim but 
not warn in failure or retry.  The most notable example is in the followup 
patch for thp, both for page faults and khugepaged, where we want to 
target the local node but silently fallback to small pages instead.

This removes the special "no reclaim" behavior of __GFP_THISNODE | 
__GFP_NORETRY | __GFP_NOWARN and relies on clearing __GFP_WAIT instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
