From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v5 2/9] xen-netback: Change TX path
 from grant copy to mapping
Date: Tue, 18 Feb 2014 18:46:47 +0000
Message-ID: <5303AA97.3010202@citrix.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>	<1390253069-25507-3-git-send-email-zoltan.kiss@citrix.com> <1392745235.23084.60.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	<xen-devel@lists.xenproject.org>, <jonathan.davies@citrix.com>,
	<wei.liu2@citrix.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392745235.23084.60.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/02/14 17:40, Ian Campbell wrote:
> On Mon, 2014-01-20 at 21:24 +0000, Zoltan Kiss wrote:
>> 
>> @@ -344,8 +346,26 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>>  	vif->pending_prod = MAX_PENDING_REQS;
>>  	for (i = 0; i < MAX_PENDING_REQS; i++)
>>  		vif->pending_ring[i] = i;
>> -	for (i = 0; i < MAX_PENDING_REQS; i++)
>> -		vif->mmap_pages[i] = NULL;
>> +	spin_lock_init(&vif->dealloc_lock);
>> +	spin_lock_init(&vif->response_lock);
>> +	/* If ballooning is disabled, this will consume real memory, so you
>> +	 * better enable it.
> 
> Almost no one who would be affected by this is going to read this
> comment. And it doesn't just require enabling ballooning, but actually
> booting with some maxmem "slack" to leave space.
> 
> Classic-xen kernels used to add 8M of slop to the physical address space
> to leave a suitable pool for exactly this sort of thing. I never liked
> that but perhaps it should be reconsidered (or at least raised as a
> possibility with the core-Xen Linux guys).

I plan to fix the balloon memory hotplug stuff to do the right thing
(it's almost there -- it just tries to overlap the new memory with
existing stuff).

David
