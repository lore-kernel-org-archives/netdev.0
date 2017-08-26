From: Ivan Delalande <colona@arista.com>
Subject: Re: [PATCH net-next v2 2/2] tcp_diag: report TCP MD5 signing keys
 and addresses
Date: Sat, 26 Aug 2017 07:53:48 +0200
Message-ID: <20170826055348.jjzv3n5vao34mkgb@ycc.fr>
References: <20170826015346.24247-1-colona@arista.com>
 <20170826015346.24247-2-colona@arista.com>
 <1503718885.11498.20.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36524 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750818AbdHZFxu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 01:53:50 -0400
Received: by mail-wm0-f46.google.com with SMTP id b79so4123587wmb.1
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 22:53:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1503718885.11498.20.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 25, 2017 at 08:41:25PM -0700, Eric Dumazet wrote:
> On Fri, 2017-08-25 at 18:53 -0700, Ivan Delalande wrote:
> > Report TCP MD5 (RFC2385) signing keys, addresses and address prefixes to
> > processes with CAP_NET_ADMIN requesting INET_DIAG_INFO. Currently it is
> > not possible to retrieve these from the kernel once they have been
> > configured on sockets.
> 
> ...
> 
> > +static int inet_diag_put_md5sig(struct sk_buff *skb,
> > +				const struct tcp_md5sig_info *md5sig)
> > +{
> > +	const struct tcp_md5sig_key *key;
> > +	struct nlattr *attr;
> > +	struct tcp_md5sig *info;
> > +	int md5sig_count = 0;
> > +
> > +	hlist_for_each_entry_rcu(key, &md5sig->head, node)
> > +		md5sig_count++;
> > +
> > +	attr = nla_reserve(skb, INET_DIAG_MD5SIG,
> > +			   md5sig_count * sizeof(struct tcp_md5sig));
> > +	if (!attr)
> > +		return -EMSGSIZE;
> > +
> > +	info = nla_data(attr);
> > +	hlist_for_each_entry_rcu(key, &md5sig->head, node) {
> > +		inet_diag_md5sig_fill(info, key);
> > +		info++;
> > +	}
> > +
> > +	return 0;
> > +}
> > +#endif
> 
> Unless I missed something, I am sure I gave a feedback on this function
> already :/

Sorry, I probably should have detailed my changes. I tried to address
this by locking the whole socket in the caller, tcp_diag_get_aux, just
outside of the rcu_read_lock. Would this work here, or do you see a
better way?

Thanks for your feedback,
-- 
Ivan Delalande
Arista Networks
