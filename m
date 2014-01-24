From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH v5] xen/grant-table: Avoid m2p_override during
 mapping
Date: Fri, 24 Jan 2014 14:44:21 +0000
Message-ID: <52E27C45.4040706@citrix.com>
References: <1390482430-9168-1-git-send-email-zoltan.kiss@citrix.com> <20140124143711.GB12946@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	<boris.ostrovsky@oracle.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140124143711.GB12946@phenom.dumpdata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24/01/14 14:37, Konrad Rzeszutek Wilk wrote:
> On Thu, Jan 23, 2014 at 01:07:10PM +0000, Zoltan Kiss wrote:
>> The grant mapping API does m2p_override unnecessarily: only gntdev needs it,
>> for blkback and future netback patches it just cause a lock contention, as
>> those pages never go to userspace. Therefore this series does the following:
>> - the original functions were renamed to __gnttab_[un]map_refs, with a new
>>   parameter m2p_override
>> - based on m2p_override either they follow the original behaviour, or just set
>>   the private flag and call set_phys_to_machine
>> - gnttab_[un]map_refs are now a wrapper to call __gnttab_[un]map_refs with
>>   m2p_override false
>> - a new function gnttab_[un]map_refs_userspace provides the old behaviour
>>
>> It also removes a stray space from page.h and change ret to 0 if
>> XENFEAT_auto_translated_physmap, as that is the only possible return value
>> there.
>>
>> v2:
>> - move the storing of the old mfn in page->index to gnttab_map_refs
>> - move the function header update to a separate patch
>>
>> v3:
>> - a new approach to retain old behaviour where it needed
>> - squash the patches into one
>>
>> v4:
>> - move out the common bits from m2p* functions, and pass pfn/mfn as parameter
>> - clear page->private before doing anything with the page, so m2p_find_override
>>   won't race with this
>>
>> v5:
>> - change return value handling in __gnttab_[un]map_refs
>> - remove a stray space in page.h
>> - add detail why ret = 0 now at some places
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>> Suggested-by: David Vrabel <david.vrabel@citrix.com>
> 
> It looks OK to me and while it is not a bug-fix I think it should
> go for v3.14 - as it _should_ improve the backends.
> 
> David or Boris; Stefano, please Ack/Nack it.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
