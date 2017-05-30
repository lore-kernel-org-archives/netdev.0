From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC net-next] arp: Really delete an arp entry on "arp
 -d"
Date: Tue, 30 May 2017 16:20:20 -0700
Message-ID: <20170530162020.137aef02@xeon-e3>
References: <1496116096-77316-1-git-send-email-sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36071 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751223AbdE3XUZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 19:20:25 -0400
Received: by mail-pf0-f182.google.com with SMTP id m17so456549pfg.3
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 16:20:24 -0700 (PDT)
In-Reply-To: <1496116096-77316-1-git-send-email-sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 May 2017 20:48:16 -0700
Sowmini Varadhan <sowmini.varadhan@oracle.com> wrote:

> +	np = &nht->hash_buckets[hash_val];
> +	while ((n = rcu_dereference_protected(*np,
> +				lockdep_is_held(&tbl->lock))) != NULL) {
> +		write_lock(&n->lock);
> +		if (n == ndel) {
> +			bool retval = false;
> +
> +			if  (atomic_read(&n->refcnt) == 1) {
> +				rcu_assign_pointer(*np,
> +					rcu_dereference_protected(n->next,
> +					lockdep_is_held(&tbl->lock)));
> +				n->dead = 1;
> +				retval = true;
> +			}
> +			write_unlock(&n->lock);
> +			if (retval)
> +				neigh_cleanup_and_release(n);
> +			write_unlock_bh(&tbl->lock);
> +			return retval;
> +		}
> +		write_unlock(&n->lock);
> +		np = &n->next;
> +	}
> +

Please don't copy/paste chunks of code. Instead refactor and make this
into a helper function. 
