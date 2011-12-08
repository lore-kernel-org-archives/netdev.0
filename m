From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/2] be2net: workaround to fix a BE bug
Date: Thu, 08 Dec 2011 00:00:44 -0500 (EST)
Message-ID: <20111208.000044.1859009201427703594.davem@davemloft.net>
References: <20111207234424.GA2385@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699Ab1LHFAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 00:00:46 -0500
In-Reply-To: <20111207234424.GA2385@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@Emulex.Com>
Date: Wed, 7 Dec 2011 17:44:24 -0600

> For vlan tagged pkts, BE
> 1) calculates checksum even when CSO is not requested
> 2) calculates checksum wrongly for padded pkt less than 60 bytes long.
> As a workaround disable TX vlan offloading in such cases.
 ...
> +	/* For vlan tagged pkts, BE
> +	 * 1) calculates checksum even when CSO is not requested
> +	 * 2) calculates checksum wrongly for padded pkt less than
> +	 * 60 bytes long.
> +	 * As a workaround disable TX vlan offloading in such cases.
> +	 */

This description either belongs in the commit message, or this
comment, but not both.

> +	if (unlikely(vlan_tx_tag_present(skb) &&
> +		(skb->ip_summed != CHECKSUM_PARTIAL || skb->len <= 60))) {

Poorly formatted, the second line openning first non-space character
needs to line up precisely after the first column after the if() statements
openning parenthesis.

If you cannot do this yourself by hand, use something like emacs's
C-mode to do it automatically for you when you hit TAB on that
second line.
