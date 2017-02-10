From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Fri, 10 Feb 2017 13:42:36 +0800
Message-ID: <811f498d-8503-78b2-1ddb-ddafdec5a385@redhat.com>
References: <CALx6S34qGUd7Zteo_sDdcXK69cOZUwiQ6wsbLfiyHW1K6gJn=A@mail.gmail.com>
 <20170209.173415.1198067959393786704.davem@davemloft.net>
 <CALx6S36ojsMZx-TW0cMCjvK07ffymPon8FDAVKMpmFRd8R-yYw@mail.gmail.com>
 <20170209.204811.352646130146676206.davem@davemloft.net>
 <CALx6S37vWi_qbBzq2Anxy6Yb5mgcQjgt7TDWYJgNJJJ13qPi2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57640 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750874AbdBJGhs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 01:37:48 -0500
In-Reply-To: <CALx6S37vWi_qbBzq2Anxy6Yb5mgcQjgt7TDWYJgNJJJ13qPi2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年02月10日 10:30, Tom Herbert wrote:
> On Thu, Feb 9, 2017 at 5:48 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Thu, 9 Feb 2017 15:08:22 -0800
>>
>>> Okay, how about this... I'll add a configuration option like
>>> XDP_ALLOW_OTHER_HOOKS. The default will be to disallow setting any
>>> hook other than a BPF. If it is set, then we'll accept other hooks
>>> to be run. This way mostly restrict the interface by default, but
>>> still allow experimentation with other hook types like I need with
>>> TXDP or maybe the netfilter guys might want to fastpath netfilter
>>> etc. When we we bring a working robust implementation to netdev that
>>> show clear benefits then we can add those to BPF as the "allowed"
>>> hooks at that time. So this strictly controls the interfaces, but
>>> still also allows room for innovation.
>> Anyone is allowed to "innovate" in their own private kernel tree.
>>
>> But I'm not unleashing that upstream.
>>
>> The only reason I accepted XDP is entirely because it is limited
>> in scope to eBPF.  All eBPF programs execute in finite time,
>> cannot loop, cannot deadlock, cannot access arbitrary pieces
>> of kernel memory and datastructures.
>>
>> It is a well defined, constrained, and incredibly tightly controlled
>> execution environment for implementing policy, monitoring and control.
> And it's also incredibly invasive in the core data path of drivers.
> TBH it is not clear to me that the narrow use cases for XDP justifies
> adding this complexity being added to every driver.

XDP is valuable for fast userspace forwarding (e.g macvtap passthrough 
mode). I hope we can leave a window for this. Or we may need introduce 
other similar hooks.

Thanks

>
> In any case, I withdraw the patch set.
>
> Tom
