From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH net] selftests/bpf: fix broken build due to types.h
Date: Tue, 16 May 2017 16:16:25 -0700
Message-ID: <a476038c-62a5-5690-c776-e5f08d120d1a@fb.com>
References: <20170516184634.2803675-1-yhs@fb.com>
 <20170516.151832.1830591267264185393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35149 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750944AbdEPXQs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 19:16:48 -0400
In-Reply-To: <20170516.151832.1830591267264185393.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 5/16/17 12:18 PM, David Miller wrote:
> 
> Please correct the address of the netdev list (it is just plain
> 'netdev' not 'linux-netdev').

Thanks. Shortly after my first email, I sent a corrected submit as well.
Sorry for the spam.

> 
> Secondly, __always_inline should not be defined by types.h
> 
> That has to come from linux/compiler.h which we have no reason
> to define a private version of for eBPF clang compilation.
> 
> The problem is that via several layers of indirection, linux/types.h
> eventually includes linux/compiler.h and that is probably the more
> appropriate thing for you to do.

Right. I found out simply including string.h will eventually include
linux/compiler.h so that I do not need explicitly defining
__always_inline.

Will send a revised patch soon.

Thanks,

Yonghong

> 
