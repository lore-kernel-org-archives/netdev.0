From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [PATCH v2 1/2] net/xen-netfront: Correct printf format in xennet_get_responses
Date: Thu, 4 Jun 2015 13:45:00 +0100
Message-ID: <5570484C.8040201@citrix.com>
References: <1433350510-12846-1-git-send-email-julien.grall@citrix.com>
	 <1433350510-12846-2-git-send-email-julien.grall@citrix.com>
 <1433351196.4861.131.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433351196.4861.131.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/06/15 18:06, Joe Perches wrote:
> On Wed, 2015-06-03 at 17:55 +0100, Julien Grall wrote:
>> rx->status is an int16_t, print it using %d rather than %u in order to
>> have a meaningful value when the field is negative.
> []
>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> []
>> @@ -733,7 +733,7 @@ static int xennet_get_responses(struct netfront_queue *queue,
>>  		if (unlikely(rx->status < 0 ||
>>  			     rx->offset + rx->status > PAGE_SIZE)) {
>>  			if (net_ratelimit())
>> -				dev_warn(dev, "rx->offset: %x, size: %u\n",
>> +				dev_warn(dev, "rx->offset: %x, size: %d\n",
> 
> If you're going to do this, perhaps it'd be sensible to
> also change the %x to %#x or 0x%x so that people don't
> mistake offset without an [a-f] for decimal.

Good idea. I will resend a version of this series.

David, can I keep you Reviewed-by for this change?

-- 
Julien Grall
