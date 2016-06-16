From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH 04/15] drivers: net: cpsw: ethtool: fix accessing to
 suspended device
Date: Thu, 16 Jun 2016 15:48:16 +0300
Message-ID: <5762A010.2070201@linaro.org>
References: <20160615115603.4897-1-grygorii.strashko@ti.com>
 <20160615115603.4897-5-grygorii.strashko@ti.com> <57617ECF.2010902@gmail.com>
 <5761860C.2020502@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>, devicetree@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5761860C.2020502@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 15.06.16 19:45, Grygorii Strashko wrote:
> On 06/15/2016 07:14 PM, Florian Fainelli wrote:
>> On 06/15/2016 04:55 AM, Grygorii Strashko wrote:
>>> The CPSW might be suspended by RPM if all ethX interfaces are down,
>>> but it still could be accesible through ethtool interfce. In this case
>>> ethtool operations, requiring registers access, will cause L3 errors and
>>> CPSW crash.
>>>
>>> Hence, fix it by adding RPM get/put calls in ethtool callbcaks which
>>> can access CPSW registers: .set_coalesce(), .get_ethtool_stats(),
>>> .set_pauseparam(), .get_regs()
>>
>> Provided that you implement an ethtool_ops::begin, it will be called
>> before each ethtool operation runs, so that could allow you to eliminate
>> some of the duplication here. Conversely ethtool_ops::end terminates
>> each operation and can be used for that purpose.
>
> Ah. Thanks for the advice. (assume you've meant .complete())

Maybe better leave as is, I'm going to add two additional ehttool ops
containing RPM sensitive part and not, better to split code on those,
if possible...and hiding put/get in begin op can call rpm when it's not
needed at all..

>
>
>

-- 
Regards,
Ivan Khoronzhuk
