From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Revert "fib_trie: use seq_file_net rather than
 seq->private"
Date: Wed, 04 Jun 2014 15:12:02 -0700 (PDT)
Message-ID: <20140604.151202.2143622064529754958.davem@davemloft.net>
References: <1401919352-32263-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dsahern@gmail.com
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401919352-32263-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Wed,  4 Jun 2014 18:02:32 -0400

> This reverts commit 30f38d2fdd79f13fc929489f7e6e517b4a4bfe63.
> 
> fib_triestat is surrounded by a big lie: while it claims that it's a
> seq_file (fib_triestat_seq_open, fib_triestat_seq_show), it isn't:
> 
> 	static const struct file_operations fib_triestat_fops = {
> 	        .owner  = THIS_MODULE,
> 	        .open   = fib_triestat_seq_open,
> 	        .read   = seq_read,
> 	        .llseek = seq_lseek,
> 	        .release = single_release_net,
> 	};
> 
> Yes, fib_triestat is just a regular file.
> 
> A small detail (assuming CONFIG_NET_NS=y) is that while for seq_files
> you could do seq_file_net() to get the net ptr, doing so for a regular
> file would be wrong and would dereference an invalid pointer.
> 
> The fib_triestat lie claimed a victim, and trying to show the file would
> be bad for the kernel. This patch just reverts the issue and fixes
> fib_triestat, which still needs a rewrite to either be a seq_file or
> stop claiming it is.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Thanks a lot for catching this, applied.
