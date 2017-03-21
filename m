From: Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Subject: Re: [v5,net-next,1/9] net: stmmac: multiple queues dt configuration
Date: Tue, 21 Mar 2017 11:39:24 +0000
Message-ID: <340aba35-de12-14a8-749c-5507edab449e@synopsys.com>
References: <c315778b650a846db3c04816fd1d1041bb1e4043.1489169213.git.jpinto@synopsys.com>
 <20170321113245.GA10526@ulmo.ba.sec>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        <alexandre.torgue-qxv4g6HH51o@public.gmane.org>, <niklas.cassel-VrBV9hrLPhE@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170321113245.GA10526-EkSeR96xj6Pcmrwk2tT4+A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi Thierry,

Às 11:32 AM de 3/21/2017, Thierry Reding escreveu:
> On Fri, Mar 10, 2017 at 06:24:51PM +0000, Joao Pinto wrote:
>> This patch adds the multiple queues configuration in the Device Tree.
>> It was also created a set of structures to keep the RX and TX queues
>> configurations to be used in the driver.
>>
>> Signed-off-by: Joao Pinto <jpinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
>> ---
>> Changes v4->v5:
>> - patch title update (stmicro replaced by stmmac)
>> Changes v2->v4:
>> - Just to keep up with patch-set version
>> Changes v1->v2:
>> - RX and TX queues child nodes had bad handle
>>
>>  Documentation/devicetree/bindings/net/stmmac.txt   | 40 ++++++++++
>>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 91 ++++++++++++++++++++++
>>  include/linux/stmmac.h                             | 30 +++++++
>>  3 files changed, 161 insertions(+)
>>
>> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
>> index d3bfc2b..4107e67 100644
>> --- a/Documentation/devicetree/bindings/net/stmmac.txt
>> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
>> @@ -72,6 +72,27 @@ Optional properties:
>>  	- snps,mb: mixed-burst
>>  	- snps,rb: rebuild INCRx Burst
>>  - mdio: with compatible = "snps,dwmac-mdio", create and register mdio bus.
>> +- Multiple RX Queues parameters: below the list of all the parameters to
>> +				 configure the multiple RX queues:
>> +	- snps,rx-queues-to-use: number of RX queues to be used in the driver
>> +	- Choose one of these RX scheduling algorithms:
>> +		- snps,rx-sched-sp: Strict priority
>> +		- snps,rx-sched-wsp: Weighted Strict priority
>> +	- For each RX queue
>> +		- Choose one of these modes:
>> +			- snps,dcb-algorithm: Queue to be enabled as DCB
>> +			- snps,avb-algorithm: Queue to be enabled as AVB
>> +		- snps,map-to-dma-channel: Channel to map
>> +- Multiple TX Queues parameters: below the list of all the parameters to
>> +				 configure the multiple TX queues:
>> +	- snps,tx-queues-to-use: number of TX queues to be used in the driver
>> +	- Choose one of these TX scheduling algorithms:
>> +		- snps,tx-sched-wrr: Weighted Round Robin
>> +		- snps,tx-sched-wfq: Weighted Fair Queuing
>> +		- snps,tx-sched-dwrr: Deficit Weighted Round Robin
>> +		- snps,tx-sched-sp: Strict priority
>> +	- For each TX queue
>> +		- snps,weight: TX queue weight (if using a weighted algorithm)
>>  
>>  Examples:
>>  
>> @@ -81,6 +102,23 @@ Examples:
>>  		snps,blen = <256 128 64 32 0 0 0>;
>>  	};
>>  
>> +	mtl_rx_setup: rx-queues-config {
>> +		snps,rx-queues-to-use = <1>;
>> +		snps,rx-sched-sp;
>> +		queue0 {
>> +			snps,dcb-algorithm;
>> +			snps,map-to-dma-channel = <0x0>;
>> +		};
>> +	};
>> +
>> +	mtl_tx_setup: tx-queues-config {
>> +		snps,tx-queues-to-use = <1>;
>> +		snps,tx-sched-wrr;
>> +		queue0 {
>> +			snps,weight = <0x10>;
>> +		};
>> +	};
>> +
>>  	gmac0: ethernet@e0800000 {
>>  		compatible = "st,spear600-gmac";
>>  		reg = <0xe0800000 0x8000>;
>> @@ -104,4 +142,6 @@ Examples:
>>  			phy1: ethernet-phy@0 {
>>  			};
>>  		};
>> +		snps,mtl-rx-config = <&mtl_rx_setup>;
>> +		snps,mtl-tx-config = <&mtl_tx_setup>;
>>  	};
> 
> That's kind of an odd placement for these nodes. Wouldn't they be better
> located within the controller's device tree node, rather than referenced
> by phandle? Making them children of the root node leaves them completely
> without context.
> 
> Thierry
> 

I followed the same approach as "stmmac_axi_setup":
https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/tree/Documentation/devicetree/bindings/net/stmmac.txt

I personally find it cleaner and easier to read.

Thanks,
Joao


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
