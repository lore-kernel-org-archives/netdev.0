From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xen-netback: include linux/vmalloc.h again
Date: Wed, 11 Jun 2014 15:19:01 -0700 (PDT)
Message-ID: <20140611.151901.986995853392690449.davem@davemloft.net>
References: <5508988.K5Wec8A6hA@wuerfel>
	<20140610084454.GB28084@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org,
	andrew.bennieston@citrix.com, xen-devel@lists.xenproject.org,
	jwboyer@fedoraproject.org
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47575 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754234AbaFKWTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:19:01 -0400
In-Reply-To: <20140610084454.GB28084@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Tue, 10 Jun 2014 09:44:54 +0100

> On Tue, Jun 10, 2014 at 10:34:36AM +0200, Arnd Bergmann wrote:
>> commit e9ce7cb6b107 ("xen-netback: Factor queue-specific data into
>> queue struct") added a use of vzalloc/vfree to interface.c, but
>> removed the #include <linux/vmalloc.h> statement at the same time,
>> which causes this build error:
>> 
>> drivers/net/xen-netback/interface.c: In function 'xenvif_free':
>> drivers/net/xen-netback/interface.c:754:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>>   vfree(vif->queues);
>>   ^
>> cc1: some warnings being treated as errors
>> 
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> Cc: Wei Liu <wei.liu2@citrix.com>
>> Cc: Andrew J. Bennieston <andrew.bennieston@citrix.com>
> 
> Acked-by: Wei Liu <wei.liu2@citrix.com>
> 
> This didn't happen to me when I built it on x86 though. Just curious,
> did you build it on othet platform, say, ARM?

ARM and PowerPC will both show this problem.

The issue is that x86 get's linux/vmalloc.h implicitly through one of
it's asm/ headers, thus you'll never hit the issue if you only build
test on that arch.
