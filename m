From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 7/9] net: macb: avoid uninitialized variables
Date: Wed, 27 Jan 2016 17:04:47 +0100
Message-ID: <56A8EA9F.6070404@atmel.com>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
 <1453903507-3427225-8-git-send-email-arnd@arndb.de>
 <56A8E788.5020802@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56A8E788.5020802@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 27/01/2016 16:51, Nicolas Ferre a =E9crit :
> Le 27/01/2016 15:04, Arnd Bergmann a =E9crit :
>> The macb_clk_init function returns three clock pointers, unless
>> the it fails to get the first ones. We correctly handle the
>> failure case by propagating the error from macb_probe, but
>> gcc does not realize this and incorrectly warns about a later
>> use of those:
>>
>> In file included from /git/arm-soc/drivers/net/ethernet/cadence/macb=
=2Ec:12:0:
>> drivers/net/ethernet/cadence/macb.c: In function 'macb_probe':
>> include/linux/clk.h:484:2: error: 'tx_clk' may be used uninitialized=
 in this function [-Werror=3Dmaybe-uninitialized]
>>   clk_disable(clk);
>>   ^
>> drivers/net/ethernet/cadence/macb.c:2822:28: note: 'tx_clk' was decl=
ared here
>>   struct clk *pclk, *hclk, *tx_clk;
>>                             ^
>> In file included from /git/arm-soc/drivers/net/ethernet/cadence/macb=
=2Ec:12:0:
>> include/linux/clk.h:484:2: error: 'hclk' may be used uninitialized i=
n this function [-Werror=3Dmaybe-uninitialized]
>>   clk_disable(clk);
>>   ^
>> drivers/net/ethernet/cadence/macb.c:2822:21: note: 'hclk' was declar=
ed here
>>   struct clk *pclk, *hclk, *tx_clk;
>>                      ^
>>
>> This shuts up the misleading warnings by ensuring that the
>> macb_clk_init() always stores something into all three pointers.
>>
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>=20
> Okay Arnd, thanks!
>=20
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Oh, crap: actually this warning has just been fixed by Sudip Mukherjee
and is already queued by David here:
https://patchwork.ozlabs.org/patch/572610/

So, sorry, I've shot too fast: NACK...

Bye,

>> ---
>>  drivers/net/ethernet/cadence/macb.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ether=
net/cadence/macb.c
>> index 9d9984a87d42..d3aa74f9db79 100644
>> --- a/drivers/net/ethernet/cadence/macb.c
>> +++ b/drivers/net/ethernet/cadence/macb.c
>> @@ -2268,6 +2268,7 @@ static int macb_clk_init(struct platform_devic=
e *pdev, struct clk **pclk,
>>  {
>>  	int err;
>> =20
>> +	*tx_clk =3D *hclk =3D NULL;
>>  	*pclk =3D devm_clk_get(&pdev->dev, "pclk");
>>  	if (IS_ERR(*pclk)) {
>>  		err =3D PTR_ERR(*pclk);
>>
>=20
>=20


--=20
Nicolas Ferre
