From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 03/20] net: pcnet: slight optimization of addr compare
Date: Tue, 24 Dec 2013 04:38:59 -0800
Message-ID: <1387888739.2259.7.camel@joe-AO722>
References: <52B96FA7.10201@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Don Fry <pcnet32@frontier.com>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0195.hostedemail.com ([216.40.44.195]:49522 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751017Ab3LXMjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 07:39:03 -0500
In-Reply-To: <52B96FA7.10201@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-24 at 19:27 +0800, Ding Tianhong wrote:
> Use possibly more efficient ether_addr_equal_unaligned
> to instead of memcmp.

Hi again Ding.

> diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
[]
> @@ -1668,7 +1668,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
[]
> -	if (memcmp(promaddr, dev->dev_addr, ETH_ALEN) ||
> +	if (!ether_addr_equal(promaddr, dev->dev_addr) ||

Can you please make sure the commit message matches the
code changes?

This uses ether_addr_equal not ether_addr_equal_unaligned.

Thanks for the work.
