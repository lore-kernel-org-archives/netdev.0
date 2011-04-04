From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Allow no-cache copy from user on transmit
Date: Sun, 03 Apr 2011 22:23:41 -0700 (PDT)
Message-ID: <20110403.222341.149838774.davem@davemloft.net>
References: <alpine.DEB.2.00.1104032136540.5452@pokey.mtv.corp.google.com>
	<20110403.220305.71570981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58416
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752001Ab1DDFYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 01:24:18 -0400
In-Reply-To: <20110403.220305.71570981.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 03 Apr 2011 22:03:05 -0700 (PDT)

> From: Tom Herbert <therbert@google.com>
> Date: Sun, 3 Apr 2011 21:56:17 -0700 (PDT)
> 
>> This patch uses __copy_from_user_nocache on transmit to bypass data
>> cache for a performance improvement.  skb_add_data_nocache and
>> skb_copy_to_page_nocache can be called by sendmsg functions to use
>> this feature, initial support is in tcp_sendmsg.  This functionality is
>> configurable per device using ethtool.
>  ...
>> Signed-off-by: Tom Herbert <therbert@google.com>
> 
> Applied, thanks Tom.

Actually, I'm sorry, I have to kick this back to you again Tom.

The original problem is that "linux/uaccess.h" has not been included
in the spot where you try to invoke the nocache copies.

linux/uaccess.h, when ARCH_HAS_NOCACHE_UACCESS is defined, provides
dummy routines.

So it's not correct to use ARCH_HAS_NOCACHE_UACCESS to conditionalize
things in the networking, just make sure linux/uaccess.h is included
at the call sites.

Thanks.
