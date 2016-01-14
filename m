From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 08/10] bus: mvenus-mbus: Fix size test for
 mvebu_mbus_get_dram_win_info
Date: Thu, 14 Jan 2016 14:00:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCC5C65@AcuExch.aculab.com>
References: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
 <1452625834-22166-9-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	"Simon Guinot" <simon.guinot@sequanux.org>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Arnd Bergmann <arnd@arndb.de>
To: 'Gregory CLEMENT' <gregory.clement@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452625834-22166-9-git-send-email-gregory.clement@free-electrons.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gregory CLEMENT
> Sent: 12 January 2016 19:11
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
>  	for (i = 0; i < dram->num_cs; i++) {
>  		const struct mbus_dram_window *cs = dram->cs + i;
> 
> -		if (cs->base <= phyaddr && phyaddr <= (cs->base + cs->size)) {
> +		if (cs->base <= phyaddr && phyaddr <= (cs->base + cs->size - 1)) {

Wouldn't it be better to change the line to:
> +		if (cs->base <= phyaddr && phyaddr < (cs->base + cs->size)) {

	David
