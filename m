From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 04/15] drivers: net: cpsw: ethtool: fix accessing to
 suspended device
Date: Wed, 15 Jun 2016 19:45:00 +0300
Message-ID: <5761860C.2020502@ti.com>
References: <20160615115603.4897-1-grygorii.strashko@ti.com>
 <20160615115603.4897-5-grygorii.strashko@ti.com> <57617ECF.2010902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57617ECF.2010902@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/15/2016 07:14 PM, Florian Fainelli wrote:
> On 06/15/2016 04:55 AM, Grygorii Strashko wrote:
>> The CPSW might be suspended by RPM if all ethX interfaces are down,
>> but it still could be accesible through ethtool interfce. In this case
>> ethtool operations, requiring registers access, will cause L3 errors and
>> CPSW crash.
>>
>> Hence, fix it by adding RPM get/put calls in ethtool callbcaks which
>> can access CPSW registers: .set_coalesce(), .get_ethtool_stats(),
>> .set_pauseparam(), .get_regs()
>
> Provided that you implement an ethtool_ops::begin, it will be called
> before each ethtool operation runs, so that could allow you to eliminate
> some of the duplication here. Conversely ethtool_ops::end terminates
> each operation and can be used for that purpose.

Ah. Thanks for the advice. (assume you've meant .complete())



-- 
regards,
-grygorii
