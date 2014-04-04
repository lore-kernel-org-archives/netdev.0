From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch iproute2] ipaddress: do not add ifa_flags when not necessary
Date: Fri, 4 Apr 2014 09:52:04 -0700
Message-ID: <CAM_iQpWyjZFMWC1dBs2x_xfH4DsppHTDBVT9xO7XN5EuVcbKow@mail.gmail.com>
References: <1396591503-16632-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140404.095905.2169727474578538143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:36773 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915AbaDDQwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 12:52:05 -0400
Received: by mail-ob0-f170.google.com with SMTP id uz6so3819714obc.29
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 09:52:04 -0700 (PDT)
In-Reply-To: <20140404.095905.2169727474578538143.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 4, 2014 at 6:59 AM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Thu,  3 Apr 2014 23:05:03 -0700
>
>> commit 37c9b94ed21d5779acc23d89a4 (add support for extended ifa_flags)
>> introduced a regression:
>>
>>       # ./ip/ip addr add 192.168.0.1/24 dev eth0
>>       RTNETLINK answers: Invalid argument
>>
>> This is due to old kernels don't support IFA_FLAGS flag, it should be skipped
>> if we don't use this feature at all.
>>
>> Cc: Jiri Pirko <jiri@resnulli.us>
>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> Your patch doesn't really fully fix the problem.
>
> If the kernel rejects because of presence of the IFA_FLAGS attribute,
> it will do so for all such cases.
>
> Therefore the guard you need is not whether ifa_flags is NULL, but
> whether a large enough flag bit is set such that IFA_FLAGS is required.
>
> IFA_FLAGS was added because ifa.ifa_flags is too small for the new
> values we needed to add.

Right, we should use IFA_FLAGS only when ifa_flags > 0xFF.

Thanks!
