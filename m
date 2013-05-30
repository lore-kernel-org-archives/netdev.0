From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Qemu-devel] [PATCH v2 1/2] net: introduce MAC_TABLE_CHANGED
 event
Date: Thu, 30 May 2013 16:57:45 +0300
Message-ID: <20130530135745.GB21440@redhat.com>
References: <20130523171834.GA31349@redhat.com>
 <20130523132633.388ee1c5@redhat.com>
 <20130524121016.GC8669@redhat.com>
 <20130524085136.4e13ab49@redhat.com>
 <20130527093425.GC6120@t430s.nay.redhat.com>
 <20130527091011.1a8bf205@redhat.com>
 <20130527092428.0ce3581d@redhat.com>
 <20130527224304.GA1822@t430s.nay.redhat.com>
 <20130528082556.2deb1095@redhat.com>
 <20130530135035.GB3860@t430s.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luiz Capitulino <lcapitulino@redhat.com>, qemu-devel@nongnu.org,
	stefanha@redhat.com, vyasevic@redhat.com, netdev@vger.kernel.org
To: Amos Kong <akong@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65219 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756517Ab3E3N5T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 09:57:19 -0400
Content-Disposition: inline
In-Reply-To: <20130530135035.GB3860@t430s.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 09:50:35PM +0800, Amos Kong wrote:
> On Tue, May 28, 2013 at 08:25:56AM -0400, Luiz Capitulino wrote:
> > On Tue, 28 May 2013 06:43:04 +0800
> > Amos Kong <akong@redhat.com> wrote:
> 
> CC: netdev, vlad
> 
> Currently we create & open macvtap device by libvirt(management),
> and pass the fd to qemu process. And macvtap works in promiscuous
> mode, we want to sync the rx-filter setup of virtio-net to macvtap
> device for better performance.
> 
> qemu might be a non-privileged process, it doesn't have permission
> to setup macvtap device. So we want to add an QMP event to notify
> management to execute the setup.
> 
> mac-programming over macvtap patch for qemu:
> http://lists.nongnu.org/archive/html/qemu-devel/2013-05/msg03337.html
> 
> 
> Can we re-consider to setup macvtap in qemu directly? open some setup
> permission of rx-filter to qemu process? will do some investigation.
>  

I don't think that's a good idea. I expect management to do more
than blindly apply anything qemu tells it to.
For example, check that host admin actually allowed this,
or verify that MAC is unique on this host.

-- 
MST
