From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH 1/4] xen/netback: implements persistent grant
 with one page pool.
Date: Fri, 16 Nov 2012 19:34:46 +0800
Message-ID: <50A624D6.2010905@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>  <1352963066-570-1-git-send-email-annie.li@oracle.com>  <50A4BC7D.6060707@citrix.com> <50A5A9CF.8030008@oracle.com> <1353058363.3499.171.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roger Pau Monne <roger.pau@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28988 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab2KPLey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 06:34:54 -0500
In-Reply-To: <1353058363.3499.171.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-16 17:32, Ian Campbell wrote:
> On Fri, 2012-11-16 at 02:49 +0000, ANNIE LI wrote:
>>> Take a look at the following functions from blkback; foreach_grant,
>>> add_persistent_gnt and get_persistent_gnt. They are generic functions to
>>> deal with persistent grants.
>> Ok, thanks.
>> Or moving those functions into a separate common file?
> Please put them somewhere common.

Ok.

>>> This is highly inefficient, one of the points of using gnttab_set_map_op
>>> is that you can queue a bunch of grants, and then map them at the same
>>> time using gnttab_map_refs, but here you are using it to map a single
>>> grant at a time. You should instead see how much grants you need to map
>>> to complete the request and map them all at the same time.
>> Yes, it is inefficient here. But this is limited by current netback
>> implementation. Current netback is not per-VIF based(not like blkback
>> does). After combining persistent grant and non persistent grant
>> together, every vif request in the queue may/may not support persistent
>> grant. I have to judge whether every vif in the queue supports
>> persistent grant or not. If it support, memcpy is used, if not,
>> grantcopy is used.
> You could (and should) still batch all the grant copies into one
> hypercall, e.g. walk the list either doing memcpy or queuing up copyops
> as appropriate, then at the end if the queue is non-zero length issue
> the hypercall.

This still connects with netback per-VIF implementation.

> I'd expect this lack of batching here and in the other case I just
> spotted to have a detrimental affect on guests running with this patch
> but not using persistent grants. Did you benchmark that case?

I did some test before.
But I'd better to create more detailed result under in different case.

>> After making netback per-VIF works, this issue can be fixed.
> You've mentioned improvements which are conditional on this work a few
> times I think, perhaps it makes sense to make that change first?

Yes, I did consider to implement per-VIF first before persistent grant. 
But thinking of it is part of wei's patch and combined with other 
patches, and decided to implement it later. But making the change first 
would make things more clear.

Thanks
Annie
> Ian.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message tomajordomo@vger.kernel.org
> More majordomo info athttp://vger.kernel.org/majordomo-info.html
