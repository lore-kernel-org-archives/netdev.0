From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] Fix panic in __d_lookup with high dentry hashtable counts
Date: Fri, 13 Jan 2012 16:22:36 +0000
Message-ID: <20120113162236.GK23916@ZenIV.linux.org.uk>
References: <20120113155237.GA25103@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
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
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120113155237.GA25103@sgi.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 13, 2012 at 09:52:37AM -0600, Dimitri Sivanich wrote:
> When the number of dentry cache hash table entries gets too high
> (2147483648 entries), use of a signed integer in the initialization
> loop prevents the dentry_hashtable from getting initialized, resulting
> in a panic in __d_lookup.  Fixing this in dcache_init and a few other
> spots for consistency.

>  static void __init dcache_init(void)
>  {
> -	int loop;
> +	long loop;

You've got to be kidding.  Note that D_HASHMASK is at most 32bit.  Use
of long here is an overkill and so's 2^31 hash buckets (that's what,
16Gb in hash list heads alone?  What kind of average chain length do
you expect, BTW?)

Can alloc_large_system_hash() produce the horrors that large, anyway?
