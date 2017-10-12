From: Wei Xu <wexu@redhat.com>
Subject: Re: Regression in throughput between kvm guests over virtual bridge
Date: Fri, 13 Oct 2017 02:31:32 +0800
Message-ID: <20171012183132.qrbgnmvki6lpgt4a@Wei-Dev>
References: <15abafa1-6d58-cd85-668a-bf361a296f52@redhat.com>
 <7345a69d-5e47-7058-c72b-bdd0f3c69210@linux.vnet.ibm.com>
 <55f9173b-a419-98f0-2516-cbd57299ba5d@redhat.com>
 <c9d43af9-f095-043a-7d46-acd84a18f75a@redhat.com>
 <7d444584-3854-ace2-008d-0fdef1c9cef4@linux.vnet.ibm.com>
 <1173ab1f-e2b6-26b3-8c3c-bd5ceaa1bd8e@redhat.com>
 <129a01d9-de9b-f3f1-935c-128e73153df6@linux.vnet.ibm.com>
 <3f824b0e-65f9-c69c-5421-2c5f6b349b09@redhat.com>
 <78678f33-c9ba-bf85-7778-b2d0676b78dd@linux.vnet.ibm.com>
 <038445a6-9dd5-30c2-aac0-ab5efbfa7024@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
        davem@davemloft.net, mst@redhat.com
To: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56668 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751937AbdJLSLK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Oct 2017 14:11:10 -0400
Content-Disposition: inline
In-Reply-To: <038445a6-9dd5-30c2-aac0-ab5efbfa7024@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 05, 2017 at 04:07:45PM -0400, Matthew Rosato wrote:
> 
> Ping...  Jason, any other ideas or suggestions?

Hi Matthew,
Recently I am doing similar test on x86 for this patch, here are some,
differences between our testbeds.

1. It is nice you have got improvement with 50+ instances(or connections here?)
which would be quite helpful to address the issue, also you've figured out the
cost(wait/wakeup), kindly reminder did you pin uperf client/server along the whole
path besides vhost and vcpu threads? 

2. It might be useful to short the traffic path as a reference, What I am running
is briefly like:
    pktgen(host kernel) -> tap(x) -> guest(DPDK testpmd)

The bridge driver(br_forward(), etc) might impact performance due to my personal
experience, so eventually I settled down with this simplified testbed which fully
isolates the traffic from both userspace and host kernel stack(1 and 50 instances,
bridge driver, etc), therefore reduces potential interferences.

The down side of this is that it needs DPDK support in guest, has this ever be
run on s390x guest? An alternative approach is to directly run XDP drop on
virtio-net nic in guest, while this requires compiling XDP inside guest which needs
a newer distro(Fedora 25+ in my case or Ubuntu 16.10, not sure).

3. BTW, did you enable hugepage for your guest? It would  performance more
or less depends on the memory demand when generating traffic, I didn't see
similar command lines in yours.

Hope this doesn't make it more complicated for you.:) We will keep working on this
and update you.

Thanks,
Wei
 



> 
