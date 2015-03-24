From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] net: use for_each_netdev_safe() in
 rtnl_group_changelink()
Date: Mon, 23 Mar 2015 17:35:52 -0700
Message-ID: <1427157352.25985.86.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427153469-32542-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34820 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbbCXAfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 20:35:54 -0400
Received: by igcau2 with SMTP id au2so58340653igc.0
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 17:35:53 -0700 (PDT)
In-Reply-To: <1427153469-32542-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-23 at 16:31 -0700, Cong Wang wrote:
> In case we move the whole dev group to another netns,
> we should call for_each_netdev_safe(), otherwise we get
> a soft lockup:


> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/core/rtnetlink.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index ee0608b..7ebed55 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1932,10 +1932,10 @@ static int rtnl_group_changelink(const struct sk_buff *skb,
>  		struct ifinfomsg *ifm,
>  		struct nlattr **tb)
>  {
> -	struct net_device *dev;
> +	struct net_device *dev, *aux;
>  	int err;
>  
> -	for_each_netdev(net, dev) {
> +	for_each_netdev_safe(net, dev, aux) {
>  		if (dev->group == group) {
>  			err = do_setlink(skb, dev, ifm, tb, NULL, 0);
>  			if (err < 0)

It seems this bug was added in commit e7ed828f10bd8, right ?

Fixes: e7ed828f10bd8 ("netlink: support setting devgroup parameters")

Thanks.
