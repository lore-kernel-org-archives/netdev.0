From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Move fib_alias out of fib_hash.c
Date: Wed, 29 Sep 2004 17:20:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16730.53965.503605.943263@robur.slu.se>
References: <20040928214722.11aef8e0.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, robert.olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040928214722.11aef8e0.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:
 > 
 > Ok, this begins the movement of fib_alias object handling
 > out of fib_hash.c  The idea is to make fib_hash.c purely
 > a longest-matching-prefix lookup implementation.
 > 
 > Look at fn_hash_lookup() after these changes, and you'll
 > get an idea of how I want the whole fib_hash.c file to look
 > in the end.


Exactly,
  we can interface new lookups cleanly. For a trie something like:

static int
fn_trie_lookup(struct fib_table *tb, const struct flowi *flp, struct fib_result *res)
{
	struct trie *t = (struct trie *) tb->tb_data;
	struct list_head *fah=NULL;
	int err=1, plen, r;

	r = trie_pfx_get(t, flp->fl4_dst, &fah, &plen);

	if (r && fah) 
		err = fib_semantic_match(fah,
					 flp, res,
					 plen);
	return err;
}



Cheers.
						--ro
