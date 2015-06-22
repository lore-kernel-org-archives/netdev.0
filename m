From: Noam Camus <noamc@ezchip.com>
Subject: RE: [PATCH v5] NET: Add ezchip ethernet driver
Date: Mon, 22 Jun 2015 14:52:48 +0000
Message-ID: <DB4PR02MB272B2804219ED0AD76BA1B2D6A10@DB4PR02MB272.eurprd02.prod.outlook.com>
References: <1434263193-16877-1-git-send-email-noamc@ezchip.com>
	<1434465342-7412-1-git-send-email-noamc@ezchip.com>
 <20150621.092218.2158342160706463595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Alexey.Brodkin@synopsys.com" <Alexey.Brodkin@synopsys.com>,
	"vgupta@synopsys.com" <vgupta@synopsys.com>,
	Gilad Ben Yossef <giladb@ezchip.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	Tal Zilcer <talz@ezchip.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0098.outbound.protection.outlook.com ([157.56.112.98]:21920
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751183AbbFVOww convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 10:52:52 -0400
In-Reply-To: <20150621.092218.2158342160706463595.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Miller [mailto:davem@davemloft.net]=20
Sent: Sunday, June 21, 2015 7:22 PM

> This builds with several warnings and also doesn't compile.
>
> drivers/net/ethernet/ezchip/nps_enet.c: In function =A1nps_enet_read_=
rx_fifo=A2:
> drivers/net/ethernet/ezchip/nps_enet.c:43:24: warning: cast from poin=
ter to integer of different size [-Wpointer-to-int-cast]
> drivers/net/ethernet/ezchip/nps_enet.c:43:24: warning: cast from poin=
ter to integer of different size [-Wpointer-to-int-cast]
> drivers/net/ethernet/ezchip/nps_enet.c: In function =A1nps_enet_send_=
frame=A2:
> drivers/net/ethernet/ezchip/nps_enet.c:366:24: warning: cast from poi=
nter to integer of different size [-Wpointer-to-int-cast]
> drivers/net/ethernet/ezchip/nps_enet.c:366:24: warning: cast from poi=
nter to integer of different size [-Wpointer-to-int-cast]
Once I start to use newer GCC (5.1.1) I get those as well. My previous =
GCC (4.8) did not report them.

> drivers/net/ethernet/ezchip/nps_enet.c: In function =A1nps_enet_poll_=
controller=A2:
> drivers/net/ethernet/ezchip/nps_enet.c:535:2: error: implicit declara=
tion of function =A1nps_enet_board_irq_handler=A2 [-Werror=3Dimplicit-f=
unction-declaration]
cc1: some warnings being treated as errors
My configuration lacked the CONFIG_NET_POLL_CONTROLLER this is why I mi=
ssed this typo caused due to renaming. I added CONFIG_NETCONSOLE to my =
configuration, now GCC report this error as well.

> I do not even see where npe_enet_board_irq_handler could possible be =
defined.
It was renamed: nps_enet_board_irq_handler -> nps_enet_irq_handler (I r=
emoved the _board).

> It is quite infuriating to receive a patch like this which is claimed=
 to be complete and ready to be applied to my tree, yet it is very clea=
rly not.
My sincerest apologies  for any problem I have made. I will send anothe=
r version that will be worth applying to your tree.

Noam
