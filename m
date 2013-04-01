From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH v2] net IPv6 : Fix broken IPv6 routing table after loopback
 down-up
Date: Mon, 01 Apr 2013 23:16:47 +0900
Message-ID: <515996CF.3030809@linux-ipv6.org>
References: <CAHPKR9L4Y0=cbH7w_iZ20CBsH=nt4UuZwyBvDOMSrMmM_sJt1w@mail.gmail.com> <CAHPKR9J4vmPp6SFn-betmb6GLimZE6dRf0Tapeu5jzyUJ=vK6Q@mail.gmail.com> <CAHPKR9J=niSHrGmeX7ZM-1fosjnRA_CFrfd+ha3zwNibNGe1bg@mail.gmail.com> <20130329.151759.1699178800809051958.davem@davemloft.net> <CAHPKR9+=fFPTpjdE+diyXDvjEdPcqcRXJvWP_rHWrqB7wMTEPA@mail.gmail.com> <515976BE.6060607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	netdev@vger.kernel.org, jamshed.a@ap.sony.com,
	amit.agarwal@ap.sony.com, takuzo.ohara@jp.sony.com,
	aaditya.kumar@ap.sony.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Balakumaran Kannan <kumaran.4353@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39937 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758038Ab3DAOQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 10:16:57 -0400
In-Reply-To: <515976BE.6060607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Balakumaran Kannan wrote:

> @@ -2540,6 +2543,31 @@ static void init_loopback(struct net_dev
>  	}
> 
>  	add_addr(idev, &in6addr_loopback, 128, IFA_HOST);
> +
> +	/* Add routes to other interface's IPv6 addresses */
> +	for_each_netdev(dev_net(dev), sp_dev) {
> +
> +		if (!strcmp(sp_dev->name, dev->name))
> +			continue;
> +
> +		idev = __in6_dev_get(sp_dev);
> +		if (NULL == idev)
> +			continue;

idev == NULL or !idev.

--yoshfuji
