From: David Miller <davem@davemloft.net>
Subject: Re: V2 [PATCH] netdevice: Fix wrong string handle in kernel
 command line parsing
Date: Tue, 01 Jul 2008 19:57:30 -0700 (PDT)
Message-ID: <20080701.195730.231191074.davem@davemloft.net>
References: <48686D7A.9030200@cn.fujitsu.com>
	<20080630102502.GG4050@solarflare.com>
	<486980C8.80706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53978
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758747AbYGBC53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 22:57:29 -0400
In-Reply-To: <486980C8.80706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 01 Jul 2008 08:56:40 +0800

> Ben Hutchings said the following on 2008-6-30 18:25:
> >> -			strcpy(s[i].name, name);
> >> +			strncpy(s[i].name, name, IFNAMSIZ);
> > 
> > I think that strncpy() should be strlcpy(), because strncpy() does not
> > ensure null-termination.
> > 
> 
> Of course. Thanks, Ben.
> 
> v1->v2: Use strlcpy() to ensure s[i].name be null-termination.
> 
> 1. In netdev_boot_setup_add(), a long name will leak.
>    ex. : dev=21,0x1234,0x1234,0x2345,eth123456789verylongname.........
> 2. In netdev_boot_setup_check(), mismatch will happen if s[i].name
>    is a substring of dev->name.
>    ex. : dev=...eth1 dev=...eth11
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Looks good, applied, thanks everyone.
