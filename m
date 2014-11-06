From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] dcbnl : Fix lock initialization
Date: Thu, 06 Nov 2014 11:03:16 -0800
Message-ID: <545BC5F4.9070501@gmail.com>
References: <1415297355-27282-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	john.r.fastabend@intel.com, ying.xue@windriver.com,
	jeffrey.t.kirsher@intel.com, ebiederm@xmission.com
To: Anish Bhatt <anish@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:49339 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaKFTDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:03:30 -0500
Received: by mail-ob0-f170.google.com with SMTP id nt9so1481568obb.15
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 11:03:30 -0800 (PST)
In-Reply-To: <1415297355-27282-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/06/2014 10:09 AM, Anish Bhatt wrote:
> dcb_lock was being used uninitialized in dcbnl and is infact missing
>   initialization code. Fixed
>

Are you trying to resolve a bug? It is initialized with

static DEFINE_SPINLOCK(dcb_lock);

and if you follow the code far enough you get to this in
spinlock_types.h:


  #ifdef CONFIG_DEBUG_SPINLOCK
  # define SPIN_DEBUG_INIT(lockname)      \
      .magic = SPINLOCK_MAGIC,        \
      .owner_cpu = -1,            \
      .owner = SPINLOCK_OWNER_INIT,
  #else
  # define SPIN_DEBUG_INIT(lockname)
  #endif

  #define __RAW_SPIN_LOCK_INITIALIZER(lockname)   \
      {                   \
      .raw_lock = __ARCH_SPIN_LOCK_UNLOCKED,  \
      SPIN_DEBUG_INIT(lockname)       \
      SPIN_DEP_MAP_INIT(lockname) }

[...]



-- 
John Fastabend         Intel Corporation
