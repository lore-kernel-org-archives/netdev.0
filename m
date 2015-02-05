From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] ipv6: addrconf: add missing validate_link_af handler
Date: Thu, 5 Feb 2015 20:11:52 +0100
Message-ID: <20150205191152.GA1965@nanopsycho.orion>
References: <0f0921b794041725c882546a614defde18fba7ea.1423143235.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:50533 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbbBETL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 14:11:56 -0500
Received: by mail-wi0-f173.google.com with SMTP id r20so41143072wiv.0
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 11:11:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <0f0921b794041725c882546a614defde18fba7ea.1423143235.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 05, 2015 at 02:39:11PM CET, daniel@iogearbox.net wrote:
>We still need a validate_link_af() handler with an appropriate nla policy,
>similarly as we have in IPv4 case, otherwise size validations are not being
>done properly in that case.
>
>Fixes: f53adae4eae5 ("net: ipv6: add tokenized interface identifier support")
>Fixes: bc91b0f07ada ("ipv6: addrconf: implement address generation modes")
>Cc: Jiri Pirko <jiri@resnulli.us>
>Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Jiri Pirko <jiri@resnulli.us>

Thanks Daniel.


>---
> net/ipv6/addrconf.c | 17 +++++++++++++++++
> 1 file changed, 17 insertions(+)
>
>diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>index f7c8bbe..dac9419 100644
>--- a/net/ipv6/addrconf.c
>+++ b/net/ipv6/addrconf.c
>@@ -4572,6 +4572,22 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
> 	return 0;
> }
> 
>+static const struct nla_policy inet6_af_policy[IFLA_INET6_MAX + 1] = {
>+	[IFLA_INET6_ADDR_GEN_MODE]	= { .type = NLA_U8 },
>+	[IFLA_INET6_TOKEN]		= { .len = sizeof(struct in6_addr) },
>+};
>+
>+static int inet6_validate_link_af(const struct net_device *dev,
>+				  const struct nlattr *nla)
>+{
>+	struct nlattr *tb[IFLA_INET6_MAX + 1];
>+
>+	if (dev && !__in6_dev_get(dev))
>+		return -EAFNOSUPPORT;
>+
>+	return nla_parse_nested(tb, IFLA_INET6_MAX, nla, inet6_af_policy);
>+}
>+
> static int inet6_set_link_af(struct net_device *dev, const struct nlattr *nla)
> {
> 	int err = -EINVAL;
>@@ -5393,6 +5409,7 @@ static struct rtnl_af_ops inet6_ops = {
> 	.family		  = AF_INET6,
> 	.fill_link_af	  = inet6_fill_link_af,
> 	.get_link_af_size = inet6_get_link_af_size,
>+	.validate_link_af = inet6_validate_link_af,
> 	.set_link_af	  = inet6_set_link_af,
> };
> 
>-- 
>1.9.3
>
