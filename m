From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net] ipv6,mcast: always hold idev->lock before mca_lock
Date: Tue, 21 May 2013 12:10:59 +0200
Message-ID: <20130521101059.GB19984@order.stressinduktion.org>
References: <1367998914-26423-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, dingtianhong <dingtianhong@huawei.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52282 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471Ab3EUKLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 06:11:00 -0400
Content-Disposition: inline
In-Reply-To: <1367998914-26423-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 08, 2013 at 03:41:54PM +0800, Cong Wang wrote:
> @@ -1596,8 +1598,8 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
>  	struct sk_buff *skb = NULL;
>  	int type;
>  
> +	read_lock_bh(&idev->lock);
>  	if (!pmc) {
> -		read_lock_bh(&idev->lock);
>  		for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
>  			if (pmc->mca_flags & MAF_NOREPORT)
>  				continue;
> @@ -1609,7 +1611,6 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
>  			skb = add_grec(skb, pmc, type, 0, 0);
>  			spin_unlock_bh(&pmc->mca_lock);
>  		}
> -		read_unlock_bh(&idev->lock);
>  	} else {
>  		spin_lock_bh(&pmc->mca_lock);
>  		if (pmc->mca_sfcount[MCAST_EXCLUDE])
> @@ -1619,6 +1620,7 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
>  		skb = add_grec(skb, pmc, type, 0, 0);
>  		spin_unlock_bh(&pmc->mca_lock);
>  	}
> +	read_unlock_bh(&idev->lock);
>  	if (skb)
>  		mld_sendpack(skb);
>  }

Isn't this hunk the only one needed to fix this problem?
