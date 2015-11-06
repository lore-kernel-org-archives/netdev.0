From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] inet: delay address promotion check until last request
 in message
Date: Sat, 7 Nov 2015 01:49:25 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1511062352270.1904@ja.home.ssi.bg>
References: <1446839495-32719-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35762 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757821AbbKFXu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2015 18:50:29 -0500
In-Reply-To: <1446839495-32719-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 6 Nov 2015, Neil Horman wrote:

> The solution is to recognize that its pointless to promote an address to be a
> new primary, if there is a possibility that it will just be removed in the near
> future.  As such this patch peeks ahead to the next request in the provided
> netlink message, and, if it is both valid and a RTM_DELADDR request, skips the
> promotion check.  This eliminates the need to iterate through a nested for loop

	flush can provide many parameters. As there is no
any kind of indication in the netlink message that all addresses
are removed, we can not avoid the promotion.

> +	 * Only check for address promotion when this is the last request
> +	 * in this netlink transaction.  It allows this operation to complete
> +	 * in O(n) time rather than O(n^2)

	It is not correct to assume that one promotion per
transaction is enough. The promotion happens in every subnet,
it was not once per device.

Regards

--
Julian Anastasov <ja@ssi.bg>
