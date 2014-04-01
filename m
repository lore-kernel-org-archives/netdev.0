From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netlink: don't compare the nul-termination in
 nla_strcmp
Date: Tue, 01 Apr 2014 15:26:06 -0400 (EDT)
Message-ID: <20140401.152606.1113760851598806005.davem@davemloft.net>
References: <1396373924-9538-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, tgraf@suug.ch
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbaDAT0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 15:26:08 -0400
In-Reply-To: <1396373924-9538-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue,  1 Apr 2014 19:38:44 +0200

> From: Pablo Neira <pablo@netfilter.org>
> 
> nla_strcmp compares the string length plus one, so it's implicitly
> including the nul-termination in the comparison.
> 
>  int nla_strcmp(const struct nlattr *nla, const char *str)
>  {
>         int len = strlen(str) + 1;
>         ...
>                 d = memcmp(nla_data(nla), str, len);
> 
> However, if NLA_STRING is used, userspace can send us a string without
> the nul-termination. This is a problem since the string
> comparison will not match as the last byte may be not the
> nul-termination.
> 
> Fix this by skipping the comparison of the nul-termination if the
> attribute data is nul-terminated. Suggested by Thomas Graf.
> 
> Cc: Florian Westphal <fw@strlen.de>
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied and queued up for -stable, thanks Pablo.
