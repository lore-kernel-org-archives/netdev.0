From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: i40e: fix shifting error in i40e_led_get
Date: Thu, 19 Dec 2013 23:41:18 +0100
Message-ID: <52B3760E.2040706@redhat.com>
References: <1387490237-27260-1-git-send-email-dborkman@redhat.com> <1387490676.2183.70.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19360 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756553Ab3LSWlX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 17:41:23 -0500
In-Reply-To: <1387490676.2183.70.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2013 11:04 PM, Jeff Kirsher wrote:
> On Thu, 2013-12-19 at 22:57 +0100, Daniel Borkmann wrote:
>> In function i40e_led_get(), we fetch the LED mode from the GPIO
>> registers and extract it from gpio_val. However, regardless of
>> the outcome of the fetched value in gpio_val, the calculation
>> to extract the mode will always be 0, as we do the following:
>>
>>    (gpio_val & (61440U /* 0xf << 12 */)) >> 17
>>
>> Instead of I40E_GLGEN_GPIO_CTL_INT_MODE_SHIFT, we need to use
>> I40E_GLGEN_GPIO_CTL_LED_MODE_SHIFT to fix this.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   Seems like this is still unfixed, so sending to netdev.
>>
>>   drivers/net/ethernet/intel/i40e/i40e_common.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> Thanks Daniel, I may already have a patch in my queue that fixes this,
> but if not, I will add this to my queue.

I reported that plus fix > 1 months ago, so I guess it seems not
yet in the queue. ;-)

Anyways, thanks Jeff!
