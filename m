From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] mm: make page pfmemalloc check more robust
Date: Fri, 14 Aug 2015 15:26:45 +0200
Message-ID: <55CDEC95.5050307@suse.cz>
References: <1439456364-4530-1-git-send-email-mhocko@kernel.org>
 <55CC5FA0.300@suse.cz>
 <1439476856.7960.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mhocko@kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>,
 Jiri Bohac <jbohac@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
 "David S. Miller" <davem@davemloft.net>, LKML
 <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
 Michal Hocko <mhocko@suse.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1439476856.7960.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 08/13/2015 04:40 PM, Eric Dumazet wrote:
> On Thu, 2015-08-13 at 11:13 +0200, Vlastimil Babka wrote:
>
>> Given that this apparently isn't the first case of this localhost issue,
>> I wonder if network code should just clear skb->pfmemalloc during send
>> (or maybe just send over localhost). That would be probably easier than
>> distinguish the __skb_fill_page_desc() callers for send vs receive.
>
> Would this still needed after this patch ?

Not until another corner case is discovered :) Or something passes a 
genuine pfmemalloc page to a socket (sending contents of some slab 
objects perhaps, where the slab page was allocated as pfmemalloc? Dunno 
if that can happen right now).

> It is sad we do not have a SNMP counter to at least count how often we
> drop skb because pfmemalloc is set.
>
> I'll provide such a patch.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
