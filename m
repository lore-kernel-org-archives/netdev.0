From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: 8% performance improved by change tap interact with kernel stack
Date: Tue, 28 Jan 2014 12:33:25 +0200
Message-ID: <20140128103325.GA17794@redhat.com>
References: <52E766D4.4070901@huawei.com>
 <20140128083459.GB16833@redhat.com>
 <52E77506.1080604@huawei.com>
 <20140128094138.GA17332@redhat.com>
 <52E78416.50000@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753485AbaA1K2l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jan 2014 05:28:41 -0500
Content-Disposition: inline
In-Reply-To: <52E78416.50000@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 28, 2014 at 06:19:02PM +0800, Qin Chuanyu wrote:
> On 2014/1/28 17:41, Michael S. Tsirkin wrote:
> >>>I think it's okay - IIUC this way we are processing xmit directly
> >>>instead of going through softirq.
> >>>Was meaning to try this - I'm glad you are looking into this.
> >>>
> >>>Could you please check latency results?
> >>>
> >>netperf UDP_RR 512
> >>test model: VM->host->host
> >>
> >>modified before : 11108
> >>modified after  : 11480
> >>
> >>3% gained by this patch
> >>
> >>
> >Nice.
> >What about CPU utilization?
> >It's trivially easy to speed up networking by
> >burning up a lot of CPU so we must make sure it's
> >not doing that.
> >And I think we should see some tests with TCP as well, and
> >try several message sizes.
> >
> >
> Yes, by burning up more CPU we could get better performance easily.
> So I have bond vhost thread and interrupt of nic on CPU1 while testing.
> 
> modified before, the idle of CPU1 is 0%-1% while testing.
> and after modify, the idle of CPU1 is 2%-3% while testing
> 
> TCP also could gain from this, but pps is less than UDP, so I think
> the improvement would be not so obviously.

Still need to test this doesn't regress but overall looks convincing to me.
Could you send a patch, accompanied by testing results for
throughput latency and cpu utilization for tcp and udp
with various message sizes?

Thanks!

-- 
MST
