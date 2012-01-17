From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] Fix panic in __d_lookup with high dentry hashtable counts
Date: Tue, 17 Jan 2012 17:25:27 +0000
Message-ID: <20120117172527.GQ23916@ZenIV.linux.org.uk>
References: <20120113155237.GA25103@sgi.com>
 <20120113162236.GK23916@ZenIV.linux.org.uk>
 <20120117171352.GA18738@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jiri Kosina <jkosina@suse.cz>, Avi Kivity <avi@redhat.com>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Dimitri Sivanich <sivanich@sgi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120117171352.GA18738@sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 17, 2012 at 11:13:52AM -0600, Dimitri Sivanich wrote:
> When the number of dentry cache hash table entries gets too high
> (2147483648 entries), as happens by default on a 16TB system, use
> of a signed integer in the dcache_init() initialization loop prevents
> the dentry_hashtable from getting initialized, causing a panic in
> __d_lookup().
> 
> In addition, the _hash_mask returned from alloc_large_system_hash() does
> not support more than a 32 bit hash table size.
> 
> Changing the _hash_mask size returned from alloc_large_system_hash() to
> support larger hash table sizes in the future, and changing loop counter
> sizes appropriately.

... and I still would like to see somebody familiar with uses of other
hashes to comment on the desirability of such monsters.  For dcache and
icache it's absolutely certain to be worse than useless.  We are talking
about 4Gbuckets here...
