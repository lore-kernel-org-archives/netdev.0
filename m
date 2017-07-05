From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH 2/2 net-next] net: stmmac: Improve documentation on AVB
 parameters
Date: Wed, 5 Jul 2017 11:34:00 +0100
Message-ID: <5ad94eb2-3379-a417-1cba-0c4f2e83274e@synopsys.com>
References: <014297b3b5a1654eda19f099082d04b79a98b16a.1496944749.git.jpinto@synopsys.com>
 <95bf7beef1abfb3c140ef56a8f59374bf6513496.1496944749.git.jpinto@synopsys.com>
 <188848c4-7159-55b2-07b2-0f8c1391a484@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <alexandre.torgue@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:50943 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751772AbdGEKeK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 06:34:10 -0400
In-Reply-To: <188848c4-7159-55b2-07b2-0f8c1391a484@st.com>
Content-Language: pt-PT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Peppe,

Às 8:10 AM de 6/9/2017, Giuseppe CAVALLARO escreveu:
> Hi Joao
> 
> On 6/8/2017 8:02 PM, Joao Pinto wrote:
>> This patch fixes the description of the DT AVB parameters and gives
>> an accurate example. It was also included the base values that were
>> used to get the example' CBS paremeter values.
>>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>> ---
>>   Documentation/devicetree/bindings/net/stmmac.txt | 24 ++++++++++++++++--------
>>   1 file changed, 16 insertions(+), 8 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt
>> b/Documentation/devicetree/bindings/net/stmmac.txt
>> index c3a7be6..707426d 100644
>> --- a/Documentation/devicetree/bindings/net/stmmac.txt
>> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
>> @@ -109,10 +109,10 @@ Optional properties:
>>                 [Attention] Queue 0 is reserved for legacy traffic
>>                 and so no AVB is available in this queue.
>>           - Configure Credit Base Shaper (if AVB Mode selected):
>> -            - snps,send_slope: enable Low Power Interface
>> -            - snps,idle_slope: unlock on WoL
>> -            - snps,high_credit: max write outstanding req. limit
>> -            - snps,low_credit: max read outstanding req. limit
>> +            - snps,send_slope: Send Slope Credit value
>> +            - snps,idle_slope:  Idle Slope Credit value
>> +            - snps,high_credit: High Credit value
>> +            - snps,low_credit: Low Credit value
>>           - snps,priority: TX queue priority (Range: 0x0 to 0xF)
>>   Examples:
>>   @@ -143,10 +143,18 @@ Examples:
>>             queue1 {
>>               snps,avb-algorithm;
>> -            snps,send_slope = <0x1000>;
>> -            snps,idle_slope = <0x1000>;
>> -            snps,high_credit = <0x3E800>;
>> -            snps,low_credit = <0xFFC18000>;
>> +            /*
>> +             *  Example AVB parameters based on:
>> +             *   Allocated Bandwidth: 40%
>> +             *   Maximum Frame size: 1000 bytes
>> +             *   Maximum Interference size: 1500 bytes
>> +             *   Port Transmit Rate: 8
>> +             *   Scaling Factor: 1024
>> +             */
>> +            snps,idle_slope = <0xCCC>;
>> +            snps,send_slope = <0x1333>;
>> +            snps,high_credit = <0x4B0000>;
> 
> Thanks for having taken care about this changes, please, as required, add a
> cover-letter
> and give more information about these values that can be tuned by user and, for
> example,
> the snps,high_credit could be as default = 0xbe4000 that is a reasonable value
> because
> comes from 1522 * 8 * 1024 and LOW credit is the two complement.
>                       ^^^^^
>                     frame size ---> maximum is 16

I calculate the hi credit this way:

  HiCredit = BW / 100 * MaxInterferenceSize * 8 * Scaling

Can I assume that you are considering 100% bandwidth for this example channel?
If so, it is not correct, since the maximum bandwidth should be 75%, leaving at
least 25% for default channel 0 (I think this is assured in the hardware).

Thanks,
Joao

> 
> Regards
> Peppe
> 
>> +            snps,low_credit = <0xFFB50000>;
>>               snps,priority = <0x1>;
>>           };
>>       };
> 
> 
