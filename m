From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 3/7]: [NET]: Do not check netif_running() and carrier state in ->poll()
Date: Tue, 8 Jan 2008 13:17:03 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702CAA89B@nekter>
References: <20080107.213907.160610552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:16270 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751835AbYAHSSN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 13:18:13 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080107.213907.160610552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This change is not required as the macro, is_s2io_card_up() checks for
an internal state of the adapter and not netif's state. We want to make
sure that the adapter registers are not accessed when the adapter is
being brought down.

> @@ -2704,9 +2704,6 @@ static int s2io_poll(struct napi_struct *napi,
int
> budget)
>  	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	int i;
> 
> -	if (!is_s2io_card_up(nic))
> -		return 0;
> -
>  	mac_control = &nic->mac_control;
>  	config = &nic->config;
> 

Ram
