From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] fix rtnl notification in atomic context
Date: Wed, 23 Oct 2013 14:03:43 -0700
Message-ID: <20131023140343.4604d80d@nehalam.linuxnetplumber.net>
References: <1382553161-3498-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35207 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129Ab3JWVDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 17:03:47 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so1496571pab.22
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 14:03:47 -0700 (PDT)
In-Reply-To: <1382553161-3498-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Oct 2013 11:32:41 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> +
> +void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change)
> +{
> +	__rtmsg_ifinfo(type, dev, change, GFP_KERNEL);
> +}
>  EXPORT_SYMBOL(rtmsg_ifinfo);
>  
>  static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
> -- 

Why add another wrapper function? I think it cleaner to just change all the
callers to use the correct gfp flags.
