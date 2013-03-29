From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] netlink: fix the warning introduced by netlink API
 replacement
Date: Fri, 29 Mar 2013 13:58:27 +0000
Message-ID: <20130329135827.GM23043@casper.infradead.org>
References: <1364402824-32680-1-git-send-email-honkiko@gmail.com>
 <1364563360-3516-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, brian.haley@hp.com
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38974 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754330Ab3C2N6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 09:58:31 -0400
Content-Disposition: inline
In-Reply-To: <1364563360-3516-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/13 at 09:22pm, Hong Zhiguo wrote:
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
> ---
>  net/ieee802154/netlink.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
> index 9247252..91b0363 100644
> --- a/net/ieee802154/netlink.c
> +++ b/net/ieee802154/netlink.c
> @@ -65,7 +65,8 @@ struct sk_buff *ieee802154_nl_create(int flags, u8 req)
>  int ieee802154_nl_mcast(struct sk_buff *msg, unsigned int group)
>  {
>  	/* XXX: nlh is right at the start of msg */
> -	void *hdr = genlmsg_data(nlmsg_data(msg->data));
> +	struct nlmsghdr *nlh = (struct nlmsghdr *)msg->data;
> +	void *hdr = genlmsg_data(nlmsg_data(nlh));

You should be using nlmsg_hdr() which would also allow to drop
the 'XXX' comment.

Obviously this was a partial API abuse that lead to these warnings
and the whole point of converting is to trigger such warnings instead
of silently accept msitakes, but it would have been great to catch
this in the first place by compiling with allmodconfig + some random
configs.
