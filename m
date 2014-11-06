From: Anish Bhatt <anish@chelsio.com>
Subject: RE: [PATCH net] dcbnl : Fix lock initialization
Date: Thu, 6 Nov 2014 19:12:03 +0000
Message-ID: <525DB349B3FB5444AE057A887CB2A8D8935DCF@nice.asicdesigners.com>
References: <1415297355-27282-1-git-send-email-anish@chelsio.com>,<545BC5F4.9070501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21123 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbaKFUKM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 15:10:12 -0500
In-Reply-To: <545BC5F4.9070501@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, without this kernel is complaining about inconsitent lock state when lock debugging is enabled. Unfortunately I do not have the trace lying around right now.

If you wish, you can reject this patch, I'll resend it when I get the trace again, with trace included.
-Anish
________________________________________
From: John Fastabend [john.fastabend@gmail.com]
Sent: Thursday, November 06, 2014 11:03 AM
To: Anish Bhatt
Cc: netdev@vger.kernel.org; davem@davemloft.net; john.r.fastabend@intel.com; ying.xue@windriver.com; jeffrey.t.kirsher@intel.com; ebiederm@xmission.com
Subject: Re: [PATCH net] dcbnl : Fix lock initialization

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
