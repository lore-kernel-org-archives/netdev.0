From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Tue, 14 Sep 2010 20:27:07 +0200
Message-ID: <20100914182707.GB15549@redhat.com>
References: <1284410580.13351.10.camel@localhost.localdomain>
 <4C8F3C77.7010302@redhat.com>
 <1284476719.13351.35.camel@localhost.localdomain>
 <201009141721.13202.arnd@arndb.de>
 <20100914152231.GA13105@redhat.com>
 <1284480025.13351.49.camel@localhost.localdomain>
 <20100914162952.GB13560@redhat.com>
 <1284483745.13351.71.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752079Ab0INSdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Sep 2010 14:33:15 -0400
Content-Disposition: inline
In-Reply-To: <1284483745.13351.71.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 14, 2010 at 10:02:25AM -0700, Shirley Ma wrote:
> On Tue, 2010-09-14 at 18:29 +0200, Michael S. Tsirkin wrote:
> > Precisely. This is what the patch from Xin Xiaohui does.  That code
> > already seems to do most of what you are trying to do, right?
> 
> I thought host pins guest kernel buffer pages was good enough for TX
> thought I didn't look up xiaohui's vhost asycn io patch in details.

As others said, the harder issues for TX are in determining that it's safe
to unpin the memory, and how much memory is it safe to pin to beging
with.  For RX we have some more complexity.

> What's the performance data Xiaohui got from using kiocb? I haven't seen
> any performance number from him yet.
> 
> > The main thing missing seems to be macvtap integration, so that we can
> > fall back
> > on data copy if zero copy is unavailable?
> > How hard would it be to basically link the mp and macvtap modules
> > together to get us this functionality? Anyone? 
> 
> The simple integration is using macvtap + xiaohui's vhost asycn io
> patch. I can make a try for TX only.
> 
> Thanks
> Shirley

Well it's up to you of course, but this is not what I would try:
if you look at the
patchset vhost changes is not the largest part of it,
so this sounds a bit like effort duplication.

TX only is also much less interesting than full zero copy.

I think that you should be able to simply combine
the two drivers together, add an ioctl to
enable/disable zero copy mode of operation.

-- 
MST
