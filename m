From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFT v3] geneve: implement support for IPv6-based tunnels
Date: Thu, 1 Oct 2015 17:38:06 +0200
Message-ID: <20151001173806.5b1d49a7@griffin>
References: <1443632696-9900-1-git-send-email-linville@tuxdriver.com>
	<1443638045-27229-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, davem@davemloft.net
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44462 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752970AbbJAPiL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 11:38:11 -0400
In-Reply-To: <1443638045-27229-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Sep 2015 14:34:05 -0400, John W. Linville wrote:
> +#if IS_ENABLED(CONFIG_IPV6)
> +static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
> +				    struct ip_tunnel_info *info)
> +{
> +	struct geneve_dev *geneve = netdev_priv(dev);
> +	struct geneve_sock *gs6 = geneve->sock6;
> +	struct dst_entry *dst = NULL;
> +	struct flowi6 fl6;
> +	__u8 ttl;
> +	__be16 sport;
> +	bool udp_csum;
> +	int err;
> +	bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
> +
> +	if (geneve->collect_md) {
> +		if (unlikely(info && info->mode != IP_TUNNEL_INFO_TX)) {

Should be !(info->mode & IP_TUNNEL_INFO_TX).

The rest looks good to me.

 Jiri

-- 
Jiri Benc
