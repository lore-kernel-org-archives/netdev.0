From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next 08/10] bus: mvenus-mbus: Fix size test for mvebu_mbus_get_dram_win_info
Date: Tue, 16 Feb 2016 17:18:52 +0100
Message-ID: <87mvr0tyqb.fsf@free-electrons.com>
References: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
	<1452625834-22166-9-git-send-email-gregory.clement@free-electrons.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCC5C65@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"linux-arm-kernel\@lists.infradead.org"
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
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCC5C65@AcuExch.aculab.com>
	(David Laight's message of "Thu, 14 Jan 2016 14:00:21 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,
 
 On jeu., janv. 14 2016, David Laight <David.Laight@ACULAB.COM> wrote:

> From: Gregory CLEMENT
>> Sent: 12 January 2016 19:11
>> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
>> ---
>>  drivers/bus/mvebu-mbus.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/bus/mvebu-mbus.c b/drivers/bus/mvebu-mbus.c
>> index 3d1c0c3880ec..214bb964165b 100644
>> --- a/drivers/bus/mvebu-mbus.c
>> +++ b/drivers/bus/mvebu-mbus.c
>> @@ -964,7 +964,7 @@ int mvebu_mbus_get_dram_win_info(phys_addr_t phyaddr, u8 *target, u8 *attr)
>>  	for (i = 0; i < dram->num_cs; i++) {
>>  		const struct mbus_dram_window *cs = dram->cs + i;
>> 
>> -		if (cs->base <= phyaddr && phyaddr <= (cs->base + cs->size)) {
>> +		if (cs->base <= phyaddr && phyaddr <= (cs->base + cs->size - 1)) {
>
> Wouldn't it be better to change the line to:
>> +		if (cs->base <= phyaddr && phyaddr < (cs->base +
>cs->size)) {

It doesn't work if there is 4GB of memory in this case we can have
cs->base + cs->size which wrap to 0 and the test fails. It was exactly
what happened on Armada XP GP board.

Gregory

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
