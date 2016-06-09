From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next v2] netvsc: get rid of completion timeouts
Date: Thu, 09 Jun 2016 10:53:34 +0200
Message-ID: <87eg86agkx.fsf@vitty.brq.redhat.com>
References: <1465406261-20233-1-git-send-email-vkuznets@redhat.com>
 <20160608.113220.1066436035256605334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160608.113220.1066436035256605334.davem@davemloft.net> (David
 Miller's message of "Wed, 08 Jun 2016 11:32:20 -0700 (PDT)")
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Vitaly Kuznetsov <vkuznets@redhat.com>
> Date: Wed,  8 Jun 2016 19:17:41 +0200
>
>> I'm hitting 5 second timeout in rndis_filter_set_rss_param() while setting
>> RSS parameters for the device. When this happens we end up returning
>> -ETIMEDOUT from the function and rndis_filter_device_add() falls back to
>> setting
>> 
>> 	net_device->max_chn = 1;
>>         net_device->num_chn = 1;
>>         net_device->num_sc_offered = 0;
>> 
>> but after a moment the rndis request succeeds and subchannels start to
>> appear. netvsc_sc_open() does unconditional nvscdev->num_sc_offered-- and
>> it becomes U32_MAX-1. Consequent rndis_filter_device_remove() will hang
>> while waiting for all U32_MAX-1 subchannels to appear and this is not
>> going to happen.
>> 
>> The immediate issue could be solved by adding num_sc_offered > 0 check to
>> netvsc_sc_open() but we're getting out of sync with the host and it's not
>> easy to adjust things later, e.g. in this particular case we'll be creating
>> queues without a user request for it and races are expected. Same applies
>> to other parts of the driver which have the same completion timeout.
>> 
>> Following the trend in drivers/hv/* code I suggest we remove all these
>> timeouts completely. As a guest we can always trust the host we're running
>> on and if the host screws things up there is no easy way to recover anyway.
>> 
>> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
>> Acked-by: Haiyang Zhang <haiyangz@microsoft.com>
>
> This doesn't apply cleanly to net-next, I get rejects.

Sorry for the screw up, apparently I forgot about my own cleanups I sent
before. v3 is coming.

-- 
  Vitaly
