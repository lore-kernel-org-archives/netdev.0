From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default configurable
Date: Wed, 01 Jul 2009 10:56:15 +0200
Message-ID: <4A4B24AF.50604@trash.net>
References: <1246379267.3749.42.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52393 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbZGAI4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 04:56:20 -0400
In-Reply-To: <1246379267.3749.42.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark McLoughlin wrote:
> With BRIDGE_NETFILTER enabled, bridge traffic is passed through
> netfilter as it is forwarded across the bridge. This is a useful
> feature in specialized cases where the admin wishes to filter bridge
> traffic based on higher-level protocol headers.
> 
> However, in a lot of cases, it causes a large amount of confusion
> since it is so counter-intuitive - nobody expects their IP firewall
> rules to also apply to traffic on their bridges.
> 
> This is especially true for virtualization, where users create a
> bridge and find that some types of traffic work and others don't, and
> it can take quite some time to identify iptables as the culprit. Users
> are often recommended to configure their iptables rules to ACCEPT
> "physdev-is-bridged" in order to avoid this confusion.
> 
> However, because nf_conntrack introduces an skb_orphan(), it is now
> recommended that bridge-nf-call-iptables be disabled completely so as
> to ensure features like TUNSETSNDBUF work as expected.
> 
> For these reasons, it makes sense to allow distributions to disable
> netfilter on the bridge by default and require those specialized users
> to enable it explicitly via sysctl.

I agree that this makes sense, at least temporarily. Mid-term
we should really fix the defaults, so it would be good to have a
feature-removal-schedule and maybe a runtime warning stating that
these defaults will change.
