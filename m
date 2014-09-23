From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH v2] net/netfilter/x_tables.c: use
 __seq_open_private()
Date: Tue, 23 Sep 2014 18:46:27 +0100
Message-ID: <1411494387.32579.138.camel@xylophone>
References: <1411491955-9131-1-git-send-email-rob.jones@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@codethink.co.uk,
	linux-kernel@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Rob Jones <rob.jones@codethink.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411491955-9131-1-git-send-email-rob.jones@codethink.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-09-23 at 18:05 +0100, Rob Jones wrote:
> Reduce boilerplate code by using __seq_open_private() instead of seq_open()
> in xt_match_open() and xt_target_open().
> 
> Signed-off-by: Rob Jones <rob.jones@codethink.co.uk>
> ---
> 
> This patch uses an existing variant of seq_open() to reduce the kernel code
> size.
> 
> The only significant variation from the pre-existing code is the fact that
> __seq_open_private() calls kzalloc() rather than kmalloc(), which could
> conceivably have an impact on timing.
> 
> This version 2 incorporates a minor initialisation simplification (resulting
> from kzalloc() being used) requested by netfilter-devel@vger.kernel.org
[...]
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -1080,7 +1080,6 @@ static void *xt_mttg_seq_start(struct seq_file *seq, loff_t *pos,
>         struct nf_mttg_trav *trav = seq->private;
>         unsigned int j;
>  
> -       trav->class = MTTG_TRAV_INIT;
>         for (j = 0; j < *pos; ++j)
>                 if (xt_mttg_seq_next(seq, NULL, NULL, is_target) == NULL)
>                         return NULL;
[...]

I'm fairly sure this simplification is wrong, as xt_mttg_seq_start() is
potentially called multiple times on the same file handle.

Ben.
