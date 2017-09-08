From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Fri, 08 Sep 2017 13:50:02 -0600
Message-ID: <57ba5e0dcd50ba74e575051d7f577400@codeaurora.org>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
 <CAM_iQpXKfUkbyuuZEZXyPrVVCoPaxnCmCARz=Jf0VtU1m9NsZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52890 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756964AbdIHTuD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 15:50:03 -0400
In-Reply-To: <CAM_iQpXKfUkbyuuZEZXyPrVVCoPaxnCmCARz=Jf0VtU1m9NsZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-09-08 10:10, Cong Wang wrote:
> On Thu, Sep 7, 2017 at 5:52 PM, Subash Abhinov Kasiviswanathan
> <subashab@codeaurora.org> wrote:
>> We are seeing a possible use after free in ip6_dst_destroy.
>> 
>> It appears as if memory of the __DST_METRICS_PTR(old) was freed in 
>> some path
>> and allocated
>> to ion driver. ion driver has also freed it. Finally the memory is 
>> freed by
>> the
>> fib gc and crashes since it is already deallocated.
> 
> Does the attach (compile-only) patch help anything?
> 
> From my _quick_ glance, it seems we miss the refcnt'ing
> right in __dst_destroy_metrics_generic().
> 
> Thanks!

Hi Cong

Thanks for patch. I'll try this out.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a 
Linux Foundation Collaborative Project
