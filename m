From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next PATCH 5/9] fib_trie: Add tnode struct as a container
 for fields not needed in key_vector
Date: Fri, 06 Mar 2015 16:17:11 +0300
Message-ID: <54F9A8D7.4070304@cogentembedded.com>
References: <20150305224208.1642.34205.stgit@ahduyck-vm-fedora20> <20150305225100.1642.67688.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:42300 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754452AbbCFNRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 08:17:14 -0500
Received: by lbjb6 with SMTP id b6so22232575lbj.9
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 05:17:12 -0800 (PST)
In-Reply-To: <20150305225100.1642.67688.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/6/2015 1:51 AM, Alexander Duyck wrote:

> This change pulls the fields not explicitly needed in the key_vector and
> placed them in the new tnode structure.  By doing this we will eventually
> be able to reduce the key_vector down to 16 bytes on 64 bit systems, and
> 12 bytes on 32 bit systems.

> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>   net/ipv4/fib_trie.c |   72 ++++++++++++++++++++++++++++-----------------------
>   1 file changed, 39 insertions(+), 33 deletions(-)
>
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index f06c92e..5e1c469 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
[...]
> @@ -316,48 +320,50 @@ static inline void empty_child_dec(struct key_vector *n)
>
>   static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
>   {
[...]
> +	struct tnode *kv = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
> +	struct key_vector *l = kv->kv;
> +
> +	if (!kv)

    You dereference 'kv' before this check.

[...]
>   static struct key_vector *tnode_new(t_key key, int pos, int bits)
>   {
> -	struct key_vector *tn = tnode_alloc(bits);
> +	struct tnode *tnode = tnode_alloc(bits);
>   	unsigned int shift = pos + bits;
> +	struct key_vector *tn = tnode->kv;
>
>   	/* verify bits and pos their msb bits clear and values are valid */
>   	BUG_ON(!bits || (shift > KEYLENGTH));
>
[...]
> +	pr_debug("AT %p s=%zu %zu\n", tnode, TNODE_SIZE(0),
>   		 sizeof(struct key_vector *) << bits);
> +
> +	if (!tnode)

    Likewise with 'tnode'.

[...]

WBR, Sergei
