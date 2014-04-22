From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: RE: Performance problem with bond interface
Date: Tue, 22 Apr 2014 10:04:25 -0700 (PDT)
Message-ID: <d1712c10-930c-46e8-b1bb-7ce764b67479@default>
References: <5e9e32bb-b60e-44d1-82be-28c4d6ec82d5@default>
 <1398095238.19600.36.camel@edumazet-glaptop2.roam.corp.google.com>
 <a4c977be-1a10-4c47-9b39-c3905161746d@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Rama Nichanamatlu <rama.nichanamatlu@oracle.com>,
	Sergey Linetskiy <sergey.linetskiy@oracle.com>,
	Vadim Makhervaks <vadim.makhervaks@oracle.com>,
	Guangyu Sun <guangyu.sun@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26474 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932737AbaDVREf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 13:04:35 -0400
In-Reply-To: <a4c977be-1a10-4c47-9b39-c3905161746d@default>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What is the purpose of initializing "features"
with NETIF_F_HW_CSUM in bond_setup() ?

[drivers/net/bonding/bond_main.c] bond-setup():
bond_dev->hw_features &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_HW_CSUM);
bond_dev->features |= bond_dev->hw_features;

If netdev_increment_features() adds features in
incremental fashion then shouldn't bond let the
features such as NETIF_F_HW_CSUM be added when
netdev_increment_features() is called for each slave
in bond_compute_features() if the slave supports it ?

Thanks.

Venkat
