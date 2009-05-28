From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 5/6]: nl80211: Eliminate reference to BUS_ID_SIZE.
Date: Thu, 28 May 2009 09:27:23 +0200
Message-ID: <1243495643.16631.7.camel@localhost.localdomain>
References: <20090526.213959.50107146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kay.sievers@vrfy.org, greg@kroah.com,
	Johannes Berg <johannes@sipsolutions.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:45354 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbZE1H1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 03:27:41 -0400
In-Reply-To: <20090526.213959.50107146.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> It's going away.  Just leave the constant "20" here so that
> behavior doesn't change.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/wireless/nl80211.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index 56d729c..4b4d3c8 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -57,7 +57,7 @@ static int get_drv_dev_by_info_ifindex(struct nlattr **attrs,
>  static struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] __read_mostly = {
>  	[NL80211_ATTR_WIPHY] = { .type = NLA_U32 },
>  	[NL80211_ATTR_WIPHY_NAME] = { .type = NLA_NUL_STRING,
> -				      .len = BUS_ID_SIZE-1 },
> +				      .len = 20-1 },
>  	[NL80211_ATTR_WIPHY_TXQ_PARAMS] = { .type = NLA_NESTED },
>  	[NL80211_ATTR_WIPHY_FREQ] = { .type = NLA_U32 },
>  	[NL80211_ATTR_WIPHY_CHANNEL_TYPE] = { .type = NLA_U32 },

this patch is actually wrong. You should remove the .len value all
together since the phy name has no limit anymore and so shouldn't the
netlink API.

Please remember to CC Johannes or John on these changes.

Regards

Marcel


