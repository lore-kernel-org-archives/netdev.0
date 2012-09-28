From: Haicheng Li <haicheng.li@linux.intel.com>
Subject: Re: [PATCH 1/2] Fix build error caused by broken PCH_PTP module dependency.
Date: Fri, 28 Sep 2012 14:57:38 +0800
Message-ID: <50654A62.5090003@linux.intel.com>
References: <5060F97F.3040809@linux.intel.com>	<20120927.180942.969924012897168294.davem@davemloft.net>	<506546A7.7030500@linux.intel.com> <20120928.024621.1635385815700269914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tshimizu818@gmail.com,
	linux-kernel@vger.kernel.org, haicheng.lee@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120928.024621.1635385815700269914.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/28/2012 02:46 PM, David Miller wrote:
> From: Haicheng Li<haicheng.li@linux.intel.com>
> Date: Fri, 28 Sep 2012 14:41:43 +0800
>
>> On 09/28/2012 06:09 AM, David Miller wrote:
>>> Look at how other people submit patches, do any other patch
>>> submissions
>>> look like your's having all of this metadata in the message body:
>> I'm sorry for it.
>>
>>> As for this specific patch:
>>>
>>>> -	depends on PTP_1588_CLOCK_PCH
>>>> +	depends on PTP_1588_CLOCK_PCH = PCH_GBE
>>>
>>> This is not the correct way to ensure that the module'ness of one
>>> config option meets the module'ness requirements of another.
>>> The correct way is to say something like "&&   (PCH_GBE || PCH_GBE=n)"
>>
>> This case is a little bit tricky than usual, with PCH_PTP selected,
>> the valid config would be either "PTP_1588_CLOCK_PCH=PCH_GBE=m" or
>> "PTP_1588_CLOCK_PCH=PCH_GBE=y", and PTP_1588_CLOCK_PCH depends on
>> PCH_GBE.
>
> And a simple "&&  PCH_GBE" should accomplish this, no?
No sir. it's actually same with the original Kconfig (by a if PCH_GBE"), it 
just failed with this config:

         CONFIG_PCH_GBE=y
         CONFIG_PCH_PTP=y
         CONFIG_PTP_1588_CLOCK=m

-haicheng
