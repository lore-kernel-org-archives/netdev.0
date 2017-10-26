From: Jose Abreu <Jose.Abreu-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] bindings: net: stmmac: Add documentation for
 TSN parameters
Date: Thu, 26 Oct 2017 08:54:06 +0100
Message-ID: <23152048-09fe-2950-e1ff-8cf90ca3f465@synopsys.com>
References: <cover.1508938927.git.joabreu@synopsys.com>
 <ef1d220cf792c74ae278e0200ca4763f9ab62d3e.1508938927.git.joabreu@synopsys.com>
 <c2a4a435-0b0b-4fa3-a69a-280f6d0c6427@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <c2a4a435-0b0b-4fa3-a69a-280f6d0c6427-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On 25-10-2017 20:34, Florian Fainelli wrote:
> On 10/25/2017 07:04 AM, Jose Abreu wrote:
>> This adds the documentation for TSN feature EST and FP.
>>
>> Signed-off-by: Jose Abreu <joabreu-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
>> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>> Cc: Joao Pinto <jpinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
>> Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
>> Cc: Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
>> Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>> ---
>>  Documentation/devicetree/bindings/net/stmmac.txt | 20 ++++++++++++++++++++
>>  1 file changed, 20 insertions(+)
>>
>> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
>> index c3a7be6..6359df6 100644
>> --- a/Documentation/devicetree/bindings/net/stmmac.txt
>> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
>> @@ -114,6 +114,16 @@ Optional properties:
>>  			- snps,high_credit: max write outstanding req. limit
>>  			- snps,low_credit: max read outstanding req. limit
>>  		- snps,priority: TX queue priority (Range: 0x0 to 0xF)
>> +- TSN parameters: below the list of all the parameters to configure TSN
>> +		  features (only applicable for IP version >= 5.00)
>> +	- snps,est: Enable EST algorithm
>> +	- If EST enabled provide these parameters:
>> +		- snps,btr: Array size of 2 with BTR value for EST algorithm
>> +		- snps,ctr: Array size of 2 with CTR value for EST algorithm
>> +		- snps,ter: TER value for EST algorithm
>> +		- snps,gcl: Variable size array with GCL table entries.
>> +	- snps,fp: Enable FP feature. This needs EST enabled.
> You are using Device Tree as a configuration interface, that does not
> sound right at all.
>
>> +
>>  Examples:
>>  
>>  	stmmac_axi_setup: stmmac-axi-config {
>> @@ -151,6 +161,15 @@ Examples:
>>  		};
>>  	};
>>  
>> +	tsn_setup: tsn-config {
>> +		snps,est;
>> +		snps,btr = <0x00000000 0x00000001>;
>> +		snps,ctr = <0x00000000 0x10000000>;
>> +		snps,ter = <0x00000000>;
>> +		snps,gcl = <0x00000001 0x00000002 0x00000003>;
>> +		snps,fp;
>> +	};
>> +
>>  	gmac0: ethernet@e0800000 {
>>  		compatible = "st,spear600-gmac";
>>  		reg = <0xe0800000 0x8000>;
>> @@ -176,4 +195,5 @@ Examples:
>>  		};
>>  		snps,mtl-rx-config = <&mtl_rx_setup>;
>>  		snps,mtl-tx-config = <&mtl_tx_setup>;
>> +		snps,tsn-config = <&tsn_setup>;
> Yes, this is definitively using Device Tree as a configuration
> interface, don't do that please.

I understand your concern here and I know DT bindings should only
describe the HW but note that this is already done in
mtl-rx-config and mtl-tx-config.

These parameters may also need to change in runtime depending on
the scheduled traffic. Unfortunately, net subsystem does not yet
support TSN so this will have to wait and for now we will use
fixed parameters.

Anyway, what do you suggest here instead? Platform data?

Best regards,
Jose Miguel Abreu
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
