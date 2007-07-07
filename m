From: KII Keiichi <k-keiichi@bx.jp.nec.com>
Subject: Re: [PATCH -mm 7/9] netconsole: Support multiple logging targets
Date: Sun, 08 Jul 2007 03:33:49 +0900
Message-ID: <468FDC8D.6080208@bx.jp.nec.com>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in> <20070704110814.28520.94417.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:40277 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547AbXGGSgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2007 14:36:53 -0400
In-Reply-To: <20070704110814.28520.94417.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Satyam,

The following comments aren't essential.

>  	if (!(event == NETDEV_UP || event == NETDEV_DOWN ||
>  	      event == NETDEV_CHANGEADDR || event == NETDEV_CHANGENAME))
> -	      	goto done;
> +		goto done;

The above diff lines are extra.

> +	spin_lock_irqsave(&target_list_lock, flags);
> +	list_for_each_entry(nt, &target_list, list) {
> +		if (nt->np.dev == dev) {
> +			switch (event) {
> +			case NETDEV_UP:
> +			case NETDEV_DOWN:
> +				nt->dev_status = net_dev_is_up(nt->np.dev);
> +				break;
> +
> +			case NETDEV_CHANGEADDR:
> +				memcpy(nt->np.local_mac, dev->dev_addr, ETH_ALEN);

The above line is over 80 characters.

Thanks,
-- 
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com



