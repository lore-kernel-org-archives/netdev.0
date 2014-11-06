From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] dcbnl : Fix lock initialization
Date: Thu, 06 Nov 2014 12:16:32 -0800
Message-ID: <545BD720.6050008@gmail.com>
References: <1415297355-27282-1-git-send-email-anish@chelsio.com>,<545BC5F4.9070501@gmail.com> <525DB349B3FB5444AE057A887CB2A8D8935DCF@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>
To: Anish Bhatt <anish@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:49163 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbaKFUQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 15:16:46 -0500
Received: by mail-oi0-f52.google.com with SMTP id u20so1322334oif.25
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 12:16:45 -0800 (PST)
In-Reply-To: <525DB349B3FB5444AE057A887CB2A8D8935DCF@nice.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/06/2014 11:12 AM, Anish Bhatt wrote:
> Yes, without this kernel is complaining about inconsitent lock state
> when lock debugging is enabled. Unfortunately I do not have the trace
> lying around right now.
>

If you have the trace that might help. I can't recall seeing any splats
in these code paths. Also as far as I can tell you shouldn't need to do
an init after the define. There are lots of examples in ./net/core where
this is done.

So we need to sort out why the init resolves the issue.

> If you wish, you can reject this patch, I'll resend it when I get the trace again, with trace included.
> -Anish
> ________________________________________
> From: John Fastabend [john.fastabend@gmail.com]
> Sent: Thursday, November 06, 2014 11:03 AM
> To: Anish Bhatt
> Cc: netdev@vger.kernel.org; davem@davemloft.net; john.r.fastabend@intel.com; ying.xue@windriver.com; jeffrey.t.kirsher@intel.com; ebiederm@xmission.com
> Subject: Re: [PATCH net] dcbnl : Fix lock initialization
>
> On 11/06/2014 10:09 AM, Anish Bhatt wrote:
>> dcb_lock was being used uninitialized in dcbnl and is infact missing
>>    initialization code. Fixed
>>
>
> Are you trying to resolve a bug? It is initialized with
>
> static DEFINE_SPINLOCK(dcb_lock);
>
> and if you follow the code far enough you get to this in
> spinlock_types.h:
>
>
>    #ifdef CONFIG_DEBUG_SPINLOCK
>    # define SPIN_DEBUG_INIT(lockname)      \
>        .magic = SPINLOCK_MAGIC,        \
>        .owner_cpu = -1,            \
>        .owner = SPINLOCK_OWNER_INIT,
>    #else
>    # define SPIN_DEBUG_INIT(lockname)
>    #endif
>
>    #define __RAW_SPIN_LOCK_INITIALIZER(lockname)   \
>        {                   \
>        .raw_lock = __ARCH_SPIN_LOCK_UNLOCKED,  \
>        SPIN_DEBUG_INIT(lockname)       \
>        SPIN_DEP_MAP_INIT(lockname) }
>
> [...]
>
>
>
> --
> John Fastabend         Intel Corporation
>


-- 
John Fastabend         Intel Corporation
