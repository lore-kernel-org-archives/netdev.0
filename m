From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH v5 1/2] geneve: implement support for IPv6-based tunnels
Date: Fri, 23 Oct 2015 13:48:49 +0900
Message-ID: <5629BC31.5070300@miraclelinux.com>
References: <1445353866-32710-1-git-send-email-linville@tuxdriver.com>
 <1445543136-8265-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Dave Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, Jiri Benc <jbenc@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33878 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbbJWEsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 00:48:53 -0400
Received: by padhk11 with SMTP id hk11so107042513pad.1
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 21:48:53 -0700 (PDT)
In-Reply-To: <1445543136-8265-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

John W. Linville wrote:
> NOTE: Link-local IPv6 addresses for remote endpoints are not supported,
> since the driver currently has no capacity for binding a geneve
> interface to a specific link.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> v5:
> - wrap declaration of sock6 in geneve_dev with IS_ENABLED(CONFIG_IPV6)
> - remove superfluous '!!' when assigning geneve->collect_md to bool
> - use skb_scrub_packet in IPv4 tx path as well 
> - check for NULL ip_tunnel_info pointer in geneve[6]_xmit_skb
> - use ipv6_addr_equal for comparing IPv6 addresses
> - more use of IS_ENABLED(CONFIG_IPV6) for preserving build integrity
> - reject link-local ipv6 address for remote tunnel endpoint
:

> @@ -870,15 +1147,35 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
:
> +
> +		if (ipv6_addr_type(&remote.sin6.sin6_addr) &
> +		    IPV6_ADDR_LINKLOCAL)
> +			netdev_dbg(dev, "link-local remote is unsupported\n");
> +			return -EINVAL;
> +	}
> +

This always returns -EINVAL; {} is missing.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
