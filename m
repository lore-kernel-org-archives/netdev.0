From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Tue, 14 Sep 2010 11:49:03 -0700
Message-ID: <1284490143.13351.82.camel@localhost.localdomain>
References: <1284410580.13351.10.camel@localhost.localdomain>
	 <4C8F3C77.7010302@redhat.com>
	 <1284476719.13351.35.camel@localhost.localdomain>
	 <201009141721.13202.arnd@arndb.de> <20100914152231.GA13105@redhat.com>
	 <1284480025.13351.49.camel@localhost.localdomain>
	 <20100914162952.GB13560@redhat.com>
	 <1284483745.13351.71.camel@localhost.localdomain>
	 <20100914182707.GB15549@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:49826 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630Ab0INStI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 14:49:08 -0400
In-Reply-To: <20100914182707.GB15549@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-09-14 at 20:27 +0200, Michael S. Tsirkin wrote:
> As others said, the harder issues for TX are in determining that it's
> safe
> to unpin the memory, and how much memory is it safe to pin to beging
> with.  For RX we have some more complexity.

I think unpin the memory is in kfree_skb() whenever the last reference
is gone for TX. What we discussed about here is when/how vhost get
notified to update ring buffer descriptors. Do I misunderstand something
here? 

> Well it's up to you of course, but this is not what I would try:
> if you look at the
> patchset vhost changes is not the largest part of it,
> so this sounds a bit like effort duplication.
> 
> TX only is also much less interesting than full zero copy.

It's not true. From the performance, TX only has gained big improvement.
We need to identify how much gain from TX zero copy, and how much gain
from RX zero copy.

> I think that you should be able to simply combine
> the two drivers together, add an ioctl to
> enable/disable zero copy mode of operation. 

That could work. But what's the purpose to have two drivers if one
driver can handle it?

Thanks
Shirley


