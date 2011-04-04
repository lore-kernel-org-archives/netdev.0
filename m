From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Allow no-cache copy from user on transmit
Date: Mon, 04 Apr 2011 09:52:07 -0700 (PDT)
Message-ID: <20110404.095207.137846978.davem@davemloft.net>
References: <20110403.220305.71570981.davem@davemloft.net>
	<20110403.222341.149838774.davem@davemloft.net>
	<BANLkTik__2JSNHXf4JBDqQPgDmMgsT9Lug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54300
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754027Ab1DDQwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 12:52:44 -0400
In-Reply-To: <BANLkTik__2JSNHXf4JBDqQPgDmMgsT9Lug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 4 Apr 2011 08:10:08 -0700

>> So it's not correct to use ARCH_HAS_NOCACHE_UACCESS to conditionalize
>> things in the networking, just make sure linux/uaccess.h is included
>> at the call sites.
>>
> Why isn't this correct?  Shouldn't it be okay if linux/uaccess.h
> (asm/uaccess.h) is always included where  ARCH_HAS_NOCACHE_UACCESS is
> used?

I'm simply saying to get rid of the ARCH_HAS_NOCACHE_UACCESS ifdefs
you're adding to the networking code, since linux/uaccess.h makes sure
that a nop version of the nocache routines are available always.

If you ifdef the networking bits unnecessarily, those code paths
won't get build tested in the majority of my test builds, which are
on sparc64.  So I want to avoid the conditionalized compilation if
at all possible.
