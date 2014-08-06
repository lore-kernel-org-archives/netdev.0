From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next 1/2] xen-netback: Using a new state bit instead
 of carrier
Date: Wed, 6 Aug 2014 19:25:03 +0100
Message-ID: <53E272FF.6030603@citrix.com>
References: <1407165658-20146-1-git-send-email-zoltan.kiss@citrix.com> <1407165658-20146-2-git-send-email-zoltan.kiss@citrix.com> <20140805124545.GD11230@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140805124545.GD11230@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/08/14 13:45, Wei Liu wrote:
> On Mon, Aug 04, 2014 at 04:20:57PM +0100, Zoltan Kiss wrote:
>> This patch introduces a new state bit VIF_STATUS_CONNECTED to track whether the
>> vif is in a connected state. Using carrier will not work with the next patch
>> in this series, which aims to turn the carrier temporarily off if the guest
>> doesn't seem to be able to receive packets.
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
>> Cc: netdev@vger.kernel.org
>> Cc: linux-kernel@vger.kernel.org
>> Cc: xen-devel@lists.xenproject.org
>>
>> v2:
>> - rename the bitshift type to "enum state_bit_shift" here, not in the next patch
>>
>> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
>> index 28c9822..4a92fc1 100644
>> --- a/drivers/net/xen-netback/common.h
>> +++ b/drivers/net/xen-netback/common.h
>> @@ -198,6 +198,11 @@ struct xenvif_queue { /* Per-queue data for xenvif */
>>   	struct xenvif_stats stats;
>>   };
>>
>> +enum state_bit_shift {
>> +	/* This bit marks that the vif is connected */
>> +	VIF_STATUS_CONNECTED
>
> This bit shift applies to vif.  In the following patch you introduce two
> more bits specifically for queues. IMHO we should avoid mixing things
> up. What about having two enums
>
>    enum vif_state_bit_shift {}
>    enum queue_state_bit_shift {}

I think it would be a bit overdoing it, this enum type is never used in 
declaration.
