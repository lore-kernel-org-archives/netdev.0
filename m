From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH net-next 01/10] net: netcp: ethss: add support of
 subsystem register region regmap
Date: Thu, 5 Jan 2017 15:42:38 -0500
Message-ID: <586EAFBE.1000500@ti.com>
References: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
 <1482271793-7671-2-git-send-email-m-karicheri2@ti.com>
 <20161222212409.arhurpl4bpqf2yw6@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <grygorii.strashko@ti.com>, <mugunthanvnm@ti.com>,
        <linux-kernel@vger.kernel.org>, <arnd@arndb.de>,
        <davem@davemloft.net>, <devicetree@vger.kernel.org>,
        <mark.rutland@arm.com>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:24033 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937255AbdAEUoi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 15:44:38 -0500
In-Reply-To: <20161222212409.arhurpl4bpqf2yw6@rob-hp-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rob,

On 12/22/2016 04:24 PM, Rob Herring wrote:
> On Tue, Dec 20, 2016 at 05:09:44PM -0500, Murali Karicheri wrote:
>> From: WingMan Kwok <w-kwok2@ti.com>
>>
>> 10gbe phy driver needs to access the 10gbe subsystem control
>> register during phy initialization. To facilitate the shared
>> access of the subsystem register region between the 10gbe Ethernet
>> driver and the phy driver, this patch adds support of the
>> subsystem register region defined by a syscon node in the dts.
>>
>> Although there is no shared access to the gbe subsystem register
>> region, using syscon for that is for the sake of consistency.
>>
>> This change is backward compatible with previously released gbe
>> devicetree bindings.
>>
>> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
>> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
>> Signed-off-by: Sekhar Nori <nsekhar@ti.com>
>> ---
>>  .../devicetree/bindings/net/keystone-netcp.txt     |  16 ++-
>>  drivers/net/ethernet/ti/netcp_ethss.c              | 140 +++++++++++++++++----
>>  2 files changed, 127 insertions(+), 29 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
>> index 04ba1dc..0854a73 100644
>> --- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
>> +++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
>> @@ -72,20 +72,24 @@ Required properties:
>>  		"ti,netcp-gbe-2" for 1GbE N NetCP 1.5 (N=2)
>>  		"ti,netcp-xgbe" for 10 GbE
>>  
>> +- syscon-subsys:	phandle to syscon node of the switch
>> +			subsystem registers.
>> +
>>  - reg:		register location and the size for the following register
>>  		regions in the specified order.
>>  		- switch subsystem registers
>> +		- sgmii module registers
> 
> This needs to go on the end of the list. Otherwise, it is not backwards 
> compatible.

Thanks for your review! I assumed backward compatibility means new kernel
should work with old DTB. The driver code is adjusted to work with both
DTBs. Isn't that enough?

Murali

> 
>>  		- sgmii port3/4 module registers (only for NetCP 1.4)
>>  		- switch module registers
>>  		- serdes registers (only for 10G)
>>  
>>  		NetCP 1.4 ethss, here is the order
>> -			index #0 - switch subsystem registers
>> +			index #0 - sgmii module registers
>>  			index #1 - sgmii port3/4 module registers
>>  			index #2 - switch module registers
>>  
>>  		NetCP 1.5 ethss 9 port, 5 port and 2 port
>> -			index #0 - switch subsystem registers
>> +			index #0 - sgmii module registers
>>  			index #1 - switch module registers
>>  			index #2 - serdes registers
>>  
>> @@ -145,6 +149,11 @@ Optional properties:
>>  
>>  Example binding:
>>  
>> +gbe_subsys: subsys@2090000 {
>> +	compatible = "syscon";
>> +	reg = <0x02090000 0x100>;
>> +};
>> +
>>  netcp: netcp@2000000 {
>>  	reg = <0x2620110 0x8>;
>>  	reg-names = "efuse";
>> @@ -163,7 +172,8 @@ netcp: netcp@2000000 {
>>  		ranges;
>>  		gbe@90000 {
>>  			label = "netcp-gbe";
>> -			reg = <0x90000 0x300>, <0x90400 0x400>, <0x90800 0x700>;
>> +			syscon-subsys = <&gbe_subsys>;
>> +			reg = <0x90100 0x200>, <0x90400 0x200>, <0x90800 0x700>;
>>  			/* enable-ale; */
>>  			tx-queue = <648>;
>>  			tx-channel = <8>;
> 


-- 
Murali Karicheri
Linux Kernel, Keystone
