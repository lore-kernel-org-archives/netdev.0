From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/13] net: simplify seq_file code
Date: Thu, 4 Feb 2010 17:58:28 -0800
Message-ID: <20100204175828.51b9e8a1.akpm@linux-foundation.org>
References: <4B6B77FE.5000104@cn.fujitsu.com>
	<4B6B780D.10003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57198 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757459Ab0BEB7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 20:59:03 -0500
In-Reply-To: <4B6B780D.10003@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 05 Feb 2010 09:44:45 +0800 Li Zefan <lizf@cn.fujitsu.com> wrote:

> +struct hlist_node *seq_hlist_start(struct hlist_head *head, loff_t pos)
> +{
> +	struct hlist_node *node;
> +
> +	hlist_for_each(node, head)
> +		if (pos-- == 0)
> +			return node;
> +	return NULL;
> +}
> +EXPORT_SYMBOL(seq_hlist_start);
> +
> +struct hlist_node *seq_hlist_start_head(struct hlist_head *head, loff_t pos)
> +{
> +	if (!pos)
> +		return SEQ_START_TOKEN;
> +
> +	return seq_hlist_start(head, pos - 1);
> +}
> +EXPORT_SYMBOL(seq_hlist_start_head);
> +
> +struct hlist_node *seq_hlist_next(void *v, struct hlist_head *head,
> +				  loff_t *ppos)
> +{
> +	struct hlist_node *node = v;
> +
> +	++*ppos;
> +	if (v == SEQ_START_TOKEN)
> +		return head->first;
> +	else
> +		return node->next;
> +}
> +EXPORT_SYMBOL(seq_hlist_next);

Oy.  Most of the global functions in seq_file.c are kerneldocumented,
as they should be!

Shouldn't seq_hlist_start_head() have been called seq_hlist_prev()?

Should seq_hlist_start() be passed *ppos, and update *ppos so the
caller can then call seq_hlist_next() and seq_hlist_prev()?

