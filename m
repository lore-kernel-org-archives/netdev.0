From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] tcp_diag: report TCP MD5 signing keys
 and addresses
Date: Fri, 25 Aug 2017 20:41:25 -0700
Message-ID: <1503718885.11498.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170826015346.24247-1-colona@arista.com>
         <20170826015346.24247-2-colona@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34131 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754289AbdHZDl2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 23:41:28 -0400
Received: by mail-pf0-f196.google.com with SMTP id p69so236447pfk.1
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 20:41:28 -0700 (PDT)
In-Reply-To: <20170826015346.24247-2-colona@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-25 at 18:53 -0700, Ivan Delalande wrote:
> Report TCP MD5 (RFC2385) signing keys, addresses and address prefixes to
> processes with CAP_NET_ADMIN requesting INET_DIAG_INFO. Currently it is
> not possible to retrieve these from the kernel once they have been
> configured on sockets.

...

> +static int inet_diag_put_md5sig(struct sk_buff *skb,
> +				const struct tcp_md5sig_info *md5sig)
> +{
> +	const struct tcp_md5sig_key *key;
> +	struct nlattr *attr;
> +	struct tcp_md5sig *info;
> +	int md5sig_count = 0;
> +
> +	hlist_for_each_entry_rcu(key, &md5sig->head, node)
> +		md5sig_count++;
> +
> +	attr = nla_reserve(skb, INET_DIAG_MD5SIG,
> +			   md5sig_count * sizeof(struct tcp_md5sig));
> +	if (!attr)
> +		return -EMSGSIZE;
> +
> +	info = nla_data(attr);
> +	hlist_for_each_entry_rcu(key, &md5sig->head, node) {
> +		inet_diag_md5sig_fill(info, key);
> +		info++;
> +	}
> +
> +	return 0;
> +}
> +#endif

Unless I missed something, I am sure I gave a feedback on this function
already :/
