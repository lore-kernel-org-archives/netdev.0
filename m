From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Fix panic in __d_lookup with high dentry hashtable
 counts
Date: Fri, 13 Jan 2012 17:15:46 +0100
Message-ID: <1326471346.3826.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120113155237.GA25103@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>,
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
In-Reply-To: <20120113155237.GA25103@sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 13 janvier 2012 =C3=A0 09:52 -0600, Dimitri Sivanich a =C3=A9=
crit :
> When the number of dentry cache hash table entries gets too high
> (2147483648 entries), use of a signed integer in the initialization
> loop prevents the dentry_hashtable from getting initialized, resultin=
g
> in a panic in __d_lookup.  Fixing this in dcache_init and a few other
> spots for consistency.

Well...

nr_dentry being an int, I dont think having a so big hash table is
needed/possible. Its probably a waste of memory ?

Maybe we should limit alloc_large_system_hash() to at most 2^30 slots.

[ And later, convert it to unsigned long *_hash_shift and unsigned long
*_hash_mask ]
