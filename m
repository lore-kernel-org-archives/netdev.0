From: Firo Yang <firogm@gmail.com>
Subject: Re: [PATCH] fib_trie: Fix potential null pointer dereference
Date: Sun, 7 Jun 2015 12:52:49 +0800
Message-ID: <20150607045249.GA4028@firo>
References: <1433590553-4672-1-git-send-email-firogm@gmail.com>
 <5572F81A.7030405@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5572F81A.7030405@bfs.de>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 06, 2015 at 03:39:38PM +0200, walter harms wrote:
>
>
>Am 06.06.2015 13:35, schrieb Firo Yang:
>> A smatch warning.
>> When kmem_cache_alloc() failed to alloc memory, a null pointer
>> will be returned. Redeference null pointer will generate
>> an unnecessary oops. So, use it after check.
>> 
>> Signed-off-by: Firo Yang <firogm@gmail.com>
>> ---
>>  net/ipv4/fib_trie.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>> index 01bce15..34094c7 100644
>> --- a/net/ipv4/fib_trie.c
>> +++ b/net/ipv4/fib_trie.c
>> @@ -326,12 +326,13 @@ static inline void empty_child_dec(struct key_vector *n)
>>  static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
>>  {
>>  	struct tnode *kv = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
>> -	struct key_vector *l = kv->kv;
>> +	struct key_vector *l;
>
>It is a good custom to have action and check close together, so this may be more
>obvious for future readers:
>	struct tnode *kv;
>	struct key_vector *l;
>
>        kv = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
>  	if (!kv)
>  		return NULL;
>
>
>re,
> wh
Thanks walter harms, I will update the patch like this.
>
>>  	/* initialize key vector */
>> +	l = kv->kv;
>>  	l->key = key;
>>  	l->pos = 0;
>>  	l->bits = 0;

-- 
