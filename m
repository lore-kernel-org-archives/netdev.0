From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix panic in __d_lookup with high dentry hashtable
 counts
Date: Tue, 17 Jan 2012 23:57:39 -0500 (EST)
Message-ID: <20120117.235739.1691577461093505587.davem@davemloft.net>
References: <20120117171352.GA18738@sgi.com>
	<20120117.122229.323838457367599504.davem@davemloft.net>
	<20120117210541.GA21940@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, paul.gortmaker@windriver.com,
	akpm@linux-foundation.org, jkosina@suse.cz, avi@redhat.com,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: sivanich@sgi.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20120117210541.GA21940@sgi.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dimitri Sivanich <sivanich@sgi.com>
Date: Tue, 17 Jan 2012 15:05:41 -0600

> On Tue, Jan 17, 2012 at 12:22:29PM -0500, David Miller wrote:
>> To be honest I think this is overkill.
>> 
>> Supporting anything larger than a 32-bit hash mask is not even close
>> to being reasonable.  Nobody needs a 4GB hash table, not for anything.
>>
> Here is a patch that keeps the 32-bit hash mask.
> 
> 
>  
> When the number of dentry cache hash table entries gets too high
> (2147483648 entries), as happens by default on a 16TB system, use
> of a signed integer in the dcache_init() initialization loop prevents
> the dentry_hashtable from getting initialized, causing a panic in
> __d_lookup().  Fix this in dcache_init() and similar areas.
> 
> Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>

This looks good to me, thanks Dimitri:

Acked-by: David S. Miller <davem@davemloft.net>
