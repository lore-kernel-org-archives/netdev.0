From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 0/3] URGENT for 3.9: net: fec: revert NAPI introduction
Date: Sat, 27 Apr 2013 15:12:04 +0800
Message-ID: <CAHrpEqRbZjXkRzfrU4RLgeB_A0uz670b=yHHuY1+HpFnD31pvw@mail.gmail.com>
References: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
	<CAOMZO5D5+bZ9NvF7HvVsne1ktZDDYPqZgomHkSaydrn2UEvBcQ@mail.gmail.com>
	<CAHrpEqQyG68v4VMDNEwcobhHqkuP_ORH9KA3OZD=2xAoJCMNOQ@mail.gmail.com>
	<1366620998.4141.28.camel@weser.hi.pengutronix.de>
	<CAHrpEqQzpLCVqyuMgD=W6ObK1Za-AcmDV7Ejxzw9xKFH57J99A@mail.gmail.com>
	<1366893085.4139.6.camel@weser.hi.pengutronix.de>
	<CAHrpEqQQZKjjnpWvV2-TCKXuQg4J3+VhX8uXDLzuYLOENmu=ig@mail.gmail.com>
	<1366901836.4139.24.camel@weser.hi.pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fabio Estevam <festevam@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:62441 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070Ab3D0HMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 03:12:06 -0400
Received: by mail-wi0-f171.google.com with SMTP id l13so1290134wie.10
        for <netdev@vger.kernel.org>; Sat, 27 Apr 2013 00:12:04 -0700 (PDT)
In-Reply-To: <1366901836.4139.24.camel@weser.hi.pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/4/25 Lucas Stach <l.stach@pengutronix.de>:
> s soon as the PHY signals a link down things start to fall apart.

Sorry, I can't reproduce your problem.

I use two MX6.
Run below command in one MX6
> ping -f -i 0 -s 1400 10.192.242.122

unplug/plug cable at the other boards.

 >uname -a
 Linux freescale 3.9.0-rc8+#214

I base on net tree.

I static analyse code. I know the possible problem.
fec_enet_adjust_link run at delay work without hold any lock.
fec_enet_adjust_link will call fec_restart reset BD queue.

fec_resart will reset BD pointer.

I think disable napi and TX queue by netif_stop_queue should resolve
your problem.

Can you give detail guide to reproduce your problem?

libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 10/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
root@freescale /proc/irq/150$ libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
libphy: 2188000.ethernet:01 - Link is Down
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
