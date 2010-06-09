From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for June 9 (niu)
Date: Wed, 09 Jun 2010 11:06:38 -0700 (PDT)
Message-ID: <20100609.110638.112605100.davem@davemloft.net>
References: <20100609133443.38f1f957.sfr@canb.auug.org.au>
	<20100609103657.66252a27.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100609103657.66252a27.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 9 Jun 2010 10:36:57 -0700

> On Wed, 9 Jun 2010 13:34:43 +1000 Stephen Rothwell wrote:
> 
>> Changes since 20100608:
>> 
>> My fixes tree contains:
>>       v4l-dvb: update gfp/slab.h includes
>>       arm: update gfp/slab.h includes
>>       davinci: update gfp/slab.h includes
>>       ocfs2: update gfp/slab.h includes
>>       acpi: update gfp/slab.h includes
> 
> 
> 
> on x86_64 or i386, CONFIG_OF_DEVICE is not enabled:
> 
> drivers/net/niu.c:9700: warning: 'struct of_device' declared inside parameter list
> drivers/net/niu.c:9700: warning: its scope is only this definition or declaration, which is probably not what you want
> drivers/net/niu.c:9716: warning: assignment from incompatible pointer type

Hmmm, I'm confused why this never happened before :-)

We conditionalize linux/of_device.h inclusion with CONFIG_SPARC64, yet
we unconditionally use "struct of_device *" pointers in the driver
with no such ifdef protection.

Even if we unconditionally included linux/of_device.h, that file does
nothing unless CONFIG_OF_DEVICE is defined so it should have always
produced these warnings since I can't see from where else it could
have gotten even a "struct of_device;" somewhere.

Do you have any idea Randy?  Pease try analyze this further so we can
fix it properly.

THanks!
