From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v7 4/9] xen-netback: Introduce TX grant mapping
Date: Thu, 13 Mar 2014 12:34:32 +0000
Message-ID: <5321A5D8.3060507@citrix.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>	 <1394142511-14827-5-git-send-email-zoltan.kiss@citrix.com> <1394705874.25873.19.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394705874.25873.19.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/03/14 10:17, Ian Campbell wrote:
> Pulling out this one comment for the attention on the core Xen/Linux
> maintainers.
>
> On Thu, 2014-03-06 at 21:48 +0000, Zoltan Kiss wrote:
> [...]
>> @@ -343,8 +347,26 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>>   	vif->pending_prod = MAX_PENDING_REQS;
>>   	for (i = 0; i < MAX_PENDING_REQS; i++)
>>   		vif->pending_ring[i] = i;
>> -	for (i = 0; i < MAX_PENDING_REQS; i++)
>> -		vif->mmap_pages[i] = NULL;
>> +	spin_lock_init(&vif->callback_lock);
>> +	spin_lock_init(&vif->response_lock);
>> +	/* If ballooning is disabled, this will consume real memory, so you
>> +	 * better enable it. The long term solution would be to use just a
>> +	 * bunch of valid page descriptors, without dependency on ballooning
>> +	 */
>
> I wonder if we ought to enforce this via Kconfig? i.e. making
> CONFIG_XEN_BACKEND (or the individual backends) depend on BALLOON (or
> select?) or by making CONFIG_XEN_BALLOON non-optional etc.
I support this idea, but let's have other's views.
>
> IIRC David V was looking into a solution involving auto hotplugging a
> new region to use for this case, but then I guess
> CONFIG_XEN_BALLOON_MEMORY_HOTPLUG would equally need to be enabled.
Yes, if that happens in the near future, we shouldn't be bothered by the 
above right now.

>
>> +	err = alloc_xenballooned_pages(MAX_PENDING_REQS,
>> +				       vif->mmap_pages,
>> +				       false);
> [...]
>
