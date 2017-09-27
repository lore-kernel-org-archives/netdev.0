From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] liquidio: fix format truncation warning
 reported by gcc 7.1.1
Date: Wed, 27 Sep 2017 09:04:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD008227C@AcuExch.aculab.com>
References: <20170926184827.GA3512@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "raghu.vatsavayi@cavium.com" <raghu.vatsavayi@cavium.com>,
        "derek.chickles@cavium.com" <derek.chickles@cavium.com>,
        "satananda.burla@cavium.com" <satananda.burla@cavium.com>
To: 'Felix Manlunas' <felix.manlunas@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:61161 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752837AbdI0JEo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 05:04:44 -0400
In-Reply-To: <20170926184827.GA3512@felix-thinkpad.cavium.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas
> Sent: 26 September 2017 19:48
> gcc 7.1.1 with -Wformat-truncation reports these warnings:
> 
> drivers/net/ethernet/cavium/liquidio/lio_core.c: In function `octeon_setup_interrupt':
> drivers/net/ethernet/cavium/liquidio/lio_core.c:1003:41: warning: `%u' directive output may be
> truncated writing between 1 and 10 bytes into a region of size between 0 and 13 [-Wformat-truncation=]
>        INTRNAMSIZ, "LiquidIO%u-pf%u-rxtx-%u",
...
> Fix them by changing the type of the "i" local variable from int to short.

That probably adds pointless code bloat by forcing the compiler to
keep masking the value with 0xffff after every arithmetic operation.

About the only architecture that doesn't suffer the penalty is x86.

Until the compiler can correctly track the domain of values (and
be given hints about the domains) this warning is, IMHO, OTT.

	David
