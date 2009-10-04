From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] connector: Removed the destruct_data callback since it
 is always kfree_skb()
Date: Sun, 4 Oct 2009 14:57:55 -0700
Message-ID: <20091004145755.90312e7e.akpm@linux-foundation.org>
References: <1254235692-1631-1-git-send-email-philipp.reisner@linbit.com>
	<1254235692-1631-2-git-send-email-philipp.reisner@linbit.com>
	<1254235692-1631-3-git-send-email-philipp.reisner@linbit.com>
	<1254235692-1631-4-git-send-email-philipp.reisner@linbit.com>
	<1254235692-1631-5-git-send-email-philipp.reisner@linbit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Lars Ellenberg <lars.ellenberg@linbit.com>
To: Philipp Reisner <philipp.reisner@linbit.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758195AbZJDV6j@vger.kernel.org>
In-Reply-To: <1254235692-1631-5-git-send-email-philipp.reisner@linbit.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Sep 2009 16:48:11 +0200 Philipp Reisner <philipp.reisner@linbit.com> wrote:

> Signed-off-by: Philipp Reisner <philipp.reisner@linbit.com>
> Acked-by: Lars Ellenberg <lars.ellenberg@linbit.com>

Please don't send unchangelogged patches.

> index 163c3e3..210338e 100644
> --- a/drivers/connector/cn_queue.c
> +++ b/drivers/connector/cn_queue.c
> @@ -83,8 +83,8 @@ void cn_queue_wrapper(struct work_struct *work)
>  
>  	d->callback(msg, nsp);
>  
> -	d->destruct_data(d->ddata);
> -	d->ddata = NULL;
> +	kfree_skb(d->skb);
> +	d->skb = NULL;
>  
>  	kfree(d->free);
>  }

So..  why is this a good thing to do?  The patchset removes the option
of ever putting anything other than an skb* into the callback data, it
does this without any dicussion or justification and it does it under
the guise of "allowing permission checking in the receiver callbacks".
