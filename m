From: Wei Xu <wexu@redhat.com>
Subject: Re: Regression in throughput between kvm guests over virtual bridge
Date: Tue, 31 Oct 2017 15:07:17 +0800
Message-ID: <20171031070717.wcbgrp6thrjmtrh3@Wei-Dev>
References: <129a01d9-de9b-f3f1-935c-128e73153df6@linux.vnet.ibm.com>
 <3f824b0e-65f9-c69c-5421-2c5f6b349b09@redhat.com>
 <78678f33-c9ba-bf85-7778-b2d0676b78dd@linux.vnet.ibm.com>
 <038445a6-9dd5-30c2-aac0-ab5efbfa7024@linux.vnet.ibm.com>
 <20171012183132.qrbgnmvki6lpgt4a@Wei-Dev>
 <c0b42b27-56f6-c2f9-9476-28d25678808a@linux.vnet.ibm.com>
 <376f8939-1990-abf6-1f5f-57b3822f94fe@redhat.com>
 <c117c0c5-7fc0-013b-6f54-2e722d115101@linux.vnet.ibm.com>
 <20171026094415.uyogf2iw7yoavnoc@Wei-Dev>
 <da80025f-6942-615f-570e-5005a25eb147@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
        netdev@vger.kernel.org, davem@davemloft.net
To: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60700 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751798AbdJaGqX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 02:46:23 -0400
Content-Disposition: inline
In-Reply-To: <da80025f-6942-615f-570e-5005a25eb147@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 01:53:12PM -0400, Matthew Rosato wrote:
> 
> > 
> > Are you using the same binding as mentioned in previous mail sent by you? it
> > might be caused by cpu convention between pktgen and vhost, could you please
> > try to run pktgen from another idle cpu by adjusting the binding? 
> 
> I don't think that's the case -- I can cause pktgen to hang in the guest
> without any cpu binding, and with vhost disabled even.

Yes, I did a test and it also hangs in guest, before we figure it out,
maybe you try udp with uperf with this case?

VM   -> Host
Host -> VM
VM   -> VM

> 
> > BTW, did you see any improvement when running pktgen from the host if no 
> > regression was found? Since this can be reproduced with only 1 vcpu for
> > guest, may you try this bind? This might help simplify the problem.
> >   vcpu0  -> cpu2
> >   vhost  -> cpu3
> >   pktgen -> cpu1 
> > 
> 
> Yes -- I ran the pktgen test from host to guest with the binding
> described.  I see an approx 5% increase in throughput from 4.12->4.13.
> Some numbers:
> 
> host-4.12: 1384486.2pps 663.8MB/sec
> host-4.13: 1434598.6pps 688.2MB/sec

That's great, at least we are aligned in this case.

Jason, any thoughts on this? 

Wei

> 
