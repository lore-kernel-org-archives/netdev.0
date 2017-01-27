From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net: ethernet: mediatek - Fix possible NULL derefrence.
Date: Fri, 27 Jan 2017 11:26:00 -0500 (EST)
Message-ID: <20170127.112600.2185367941561923892.davem@davemloft.net>
References: <CGME20170127111947epcas2p14f5ea86f0069142be02339754fda4a55@epcas2p1.samsung.com>
 <1485515980-3814-1-git-send-email-shailendra.v@samsung.com>
 <20170127124449.GB13611@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, ashish.kalra@samsung.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, p.shailesh@samsung.com,
 linux-mediatek@lists.infradead.org, shailendra.v@samsung.com,
 matthias.bgg@gmail.com, shailendra.capricorn@gmail.com,
 linux-arm-kernel@lists.infradead.org, blogic@openwrt.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170127124449.GB13611@Red>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Fri, 27 Jan 2017 13:44:49 +0100

> On Fri, Jan 27, 2017 at 04:49:40PM +0530, Shailendra Verma wrote:
>> of_match_device could return NULL, and so can cause a NULL
>> pointer dereference later.
>> 
>> Signed-off-by: Shailendra Verma <shailendra.v@samsung.com>
>> ---
>>  drivers/net/ethernet/mediatek/mtk_eth_soc.c |    4 ++++
>>  1 file changed, 4 insertions(+)
>> 
>> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> index 4a62ffd..4495b7b 100644
>> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> @@ -2369,6 +2369,10 @@ static int mtk_probe(struct platform_device *pdev)
>>  	int i;
>>  
>>  	match = of_match_device(of_mtk_match, &pdev->dev);
>> +	if (!match) {
>> +		dev_err(&pdev->dev, "Error: No device match found\n");
>> +		return -ENODEV;
>> +	}
>>  	soc = (struct mtk_soc_data *)match->data;
>>  
>>  	eth = devm_kzalloc(&pdev->dev, sizeof(*eth), GFP_KERNEL);
>> -- 
> 
> Hello
> 
> You could use of_device_get_match_data() and simplifiy code

Agreed.
