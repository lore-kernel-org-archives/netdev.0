From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: Revert "fib_trie: use seq_file_net rather than seq->private"
Date: Thu, 05 Jun 2014 02:11:54 +0400
Message-ID: <538F99AA.2080005@cogentembedded.com>
References: <1401919352-32263-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dsahern@gmail.com
To: Sasha Levin <sasha.levin@oracle.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401919352-32263-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/05/2014 02:02 AM, Sasha Levin wrote:

> This reverts commit 30f38d2fdd79f13fc929489f7e6e517b4a4bfe63.

> fib_triestat is surrounded by a big lie: while it claims that it's a
> seq_file (fib_triestat_seq_open, fib_triestat_seq_show), it isn't:

> 	static const struct file_operations fib_triestat_fops = {
> 	        .owner  = THIS_MODULE,
> 	        .open   = fib_triestat_seq_open,
> 	        .read   = seq_read,
> 	        .llseek = seq_lseek,
> 	        .release = single_release_net,
> 	};

> Yes, fib_triestat is just a regular file.

> A small detail (assuming CONFIG_NET_NS=y) is that while for seq_files
> you could do seq_file_net() to get the net ptr, doing so for a regular
> file would be wrong and would dereference an invalid pointer.
>
> The fib_triestat lie claimed a victim, and trying to show the file would
> be bad for the kernel. This patch just reverts the issue and fixes
> fib_triestat, which still needs a rewrite to either be a seq_file or
> stop claiming it is.

> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>   net/ipv4/fib_trie.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 243c7f4..5afeb5a 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -2166,7 +2166,7 @@ static void fib_table_print(struct seq_file *seq, struct fib_table *tb)
>
>   static int fib_triestat_seq_show(struct seq_file *seq, void *v)
>   {
> -	struct net *net = seq_file_net(seq);
> +	struct net *net = (struct net *)seq->private;

    'void *' doesn't need any explicit casting to another pointer type, the 
cast it automatic.

WBR, Sergei
