From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 6/6] vhost_net: don't poll on -EFAULT
Date: Tue, 17 Apr 2012 13:18:20 +0300
Message-ID: <20120417101820.GB20905@redhat.com>
References: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com>
 <20120416060833.14140.28139.stgit@intel-e5620-16-2.englab.nay.redhat.com>
 <20120416071646.GB25396@redhat.com>
 <4F8BD81A.7010507@redhat.com>
 <20120416133859.GB13190@redhat.com>
 <4F8CE305.9090100@redhat.com>
 <20120417045736.GA31278@redhat.com>
 <4F8D05AF.4000309@redhat.com>
 <20120417060752.GB20674@redhat.com>
 <4F8D0E03.7030105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xma@us.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7078 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750909Ab2DQKSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 06:18:11 -0400
Content-Disposition: inline
In-Reply-To: <4F8D0E03.7030105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 17, 2012 at 02:30:27PM +0800, Jason Wang wrote:
> On 04/17/2012 02:07 PM, Michael S. Tsirkin wrote:
> >On Tue, Apr 17, 2012 at 01:54:55PM +0800, Jason Wang wrote:
> >>On 04/17/2012 12:57 PM, Michael S. Tsirkin wrote:
> >>>On Tue, Apr 17, 2012 at 11:27:01AM +0800, Jason Wang wrote:
> >>>>On 04/16/2012 09:39 PM, Michael S. Tsirkin wrote:
> >>>>>On Mon, Apr 16, 2012 at 04:28:10PM +0800, Jason Wang wrote:
> >>>>>>>  On 04/16/2012 03:16 PM, Michael S. Tsirkin wrote:
> >>>>>>>>  >On Mon, Apr 16, 2012 at 02:08:33PM +0800, Jason Wang wrote:
> >>>>>>>>>  >>Currently, we restart tx polling unconditionally when sendmsg()
> >>>>>>>>>  >>fails. This would cause unnecessary wakeups of vhost wokers as it's
> >>>>>>>>>  >>only needed when the socket send buffer were exceeded.
> >>>>>>>>  >Why is this a problem?
> >>>>>>>  >    This issue is when guest driver is able to hit the
> >>>>>>-EFAULT, vhost
> >>>>>>>  discard the the descriptor and restart the polling. This would wake
> >>>>>>>  vhost thread and repeat the loop again which waste cpu.
> >>>>>Does same thing happen if we get an error from copy from user?
> >>>>>
> >>>>Right, so do you think it makes sense that we only restart polling
> >>>>on -EAGAIN or -ENOBUFS?
> >>>Sounds OK. BTW how do you test this?
> >>>
> >>Not very hard, w/o this patch, we can see almost 100% cpu
> >>utilization for vhost thread if guest hit EFAULT or EINVAL. With
> >>this patch, the cpu utilization should be very low I think.
> >Yes but do you have a test that makes guest hit EFAULT or EINVAL?
> 
> Looks like we can do this by supplying an invalid hdr_len in vnet
> header as tap does the check for this.

Ah so you patched qemu to do this? Cool. Can you post the patch for testing pls?

> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
