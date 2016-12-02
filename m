From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 5/7] Documentation: DT: net: cpsw: allow to specify
 descriptors pool size
Date: Fri, 2 Dec 2016 11:22:28 -0600
Message-ID: <31a048c2-74e4-772e-ab63-9eacc2f49953@ti.com>
References: <20161201233432.6182-1-grygorii.strashko@ti.com>
 <20161201233432.6182-6-grygorii.strashko@ti.com>
 <20161202112832.GB1213@khorivan>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161202112832.GB1213@khorivan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/02/2016 05:28 AM, Ivan Khoronzhuk wrote:
> On Thu, Dec 01, 2016 at 05:34:30PM -0600, Grygorii Strashko wrote:
>> Add optional property "descs_pool_size" to specify buffer descriptor's
>> pool size. The "descs_pool_size" should define total number of CPDMA
>> CPPI descriptors to be used for both ingress/egress packets
>> processing. If not specified - the default value 256 will be used
>> which will allow to place descriptor's pool into the internal CPPI
>> RAM on most of TI SoC.
>>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> ---
>>  Documentation/devicetree/bindings/net/cpsw.txt | 5 +++++
>>  1 file changed, 5 insertions(+)
>>
>> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
>> index 5ad439f..b99d196 100644
>> --- a/Documentation/devicetree/bindings/net/cpsw.txt
>> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
>> @@ -35,6 +35,11 @@ Optional properties:
>>  			  For example in dra72x-evm, pcf gpio has to be
>>  			  driven low so that cpsw slave 0 and phy data
>>  			  lines are connected via mux.
>> +- descs_pool_size	: total number of CPDMA CPPI descriptors to be used for
>> +			  both ingress/egress packets processing. if not
>> +			  specified the default value 256 will be used which
>> +			  will allow to place descriptors pool into the
>> +			  internal CPPI RAM.
> Does it describe h/w? Why now module parameter? or even smth like ethtool num
> ring entries?
> 

It can be module parameter too. in general this is expected to be 
 one-time boot setting only.  

----- OR
So, do you propose to use 
       ethtool -g ethX

       ethtool -G ethX [rx N] [tx N]
?

Now cpdma has one pool for all RX/TX channels, so changing this settings
by ethtool will require: pause interfaces, reallocate cpdma pool, 
re-arrange buffers between channels, resume interface. Correct?

How do you think - we can move forward with one pool or better to have two (Rx and Tx)?

Wouldn't it be reasonable to still have DT (or module) parameter to avoid 
cpdma reconfiguration on system startup (pause/resume interfaces) (faster boot)?

How about cpdma re-allocation policy (with expectation that is shouldn't happen too often)?
- increasing of Rx, Tx will grow total number of physically allocated buffers (total_desc_num)
- decreasing of Rx, Tx will just change number of available buffers (no memory re-allocation)

----- OR ----
Can we move forward with current patch (total number of CPDMA CPPI descriptors defined in DT) 
and add ethtool -G ethX [rx N] [tx N] which will allow to re-split descs between RX and TX?



-- 
regards,
-grygorii
