From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH net-next 08/10] bus: mvenus-mbus: Fix size test for mvebu_mbus_get_dram_win_info
Date: Tue, 12 Jan 2016 22:42:49 +0100
Message-ID: <CAPv3WKcDNPY=h37ZiVp8nESmeCZYHBuU0q30D0NoymWoTvz+wA@mail.gmail.com>
References: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
	<1452625834-22166-9-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Arnd Bergmann <arnd@arndb.de>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:33739 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467AbcALVmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 16:42:50 -0500
Received: by mail-ob0-f178.google.com with SMTP id is5so38828173obc.0
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 13:42:49 -0800 (PST)
In-Reply-To: <1452625834-22166-9-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gregory,



2016-01-12 20:10 GMT+01:00 Gregory CLEMENT <gregory.clement@free-electrons.com>:
> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
> ---
>  drivers/bus/mvebu-mbus.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/bus/mvebu-mbus.c b/drivers/bus/mvebu-mbus.c
> index 3d1c0c3880ec..214bb964165b 100644
> --- a/drivers/bus/mvebu-mbus.c
> +++ b/drivers/bus/mvebu-mbus.c
> @@ -964,7 +964,7 @@ int mvebu_mbus_get_dram_win_info(phys_addr_t phyaddr, u8 *target, u8 *attr)
>         for (i = 0; i < dram->num_cs; i++) {
>                 const struct mbus_dram_window *cs = dram->cs + i;
>
> -               if (cs->base <= phyaddr && phyaddr <= (cs->base + cs->size)) {
> +               if (cs->base <= phyaddr && phyaddr <= (cs->base + cs->size - 1)) {
>                         *target = dram->mbus_dram_target_id;
>                         *attr = cs->mbus_attr;
>                         return 0;
> --

Except for a typo in the commit log, the fix is good.
If you wish you can add
Reviewed-by: Marcin Wojtas <mw@semihalf.com>

Best regards,
Marcin
