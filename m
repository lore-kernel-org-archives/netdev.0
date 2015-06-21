From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: disable HiSax NetJet driver on microblaze arch
Date: Sun, 21 Jun 2015 09:54:00 -0700 (PDT)
Message-ID: <20150621.095400.890337700038231482.davem@davemloft.net>
References: <87pp4vw3ep.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	isdn@linux-pingi.de, jdelvare@suse.de
To: nicstange@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87pp4vw3ep.fsf@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolai Stange <nicstange@gmail.com>
Date: Wed, 17 Jun 2015 03:05:02 +0200

> Fix an allmodconfig compilation failer on microblaze due to big endian
> architectures being apparently unsupported by the NetJet code:
>   drivers/isdn/hisax/nj_s.c: In function 'setup_netjet_s':
>   drivers/isdn/hisax/nj_s.c:265:2:
>       error: #error "not running on big endian machines now"
> 
> Modify the relevant Kconfig such that the NetJet code is not built on
> microblaze anymore.
> 
> Note that endianess on microblaze is not determined through Kconfig,
> but by means of a compiler provided CPP macro, namely __MICROBLAZEEL__.
> However, gcc defaults to big endianess on that platform.
> 
> Signed-off-by: Nicolai Stange <nicstange@gmail.com>
> ---
>  The maintainer tree listed under "ISDN SUBSYSTEM" in MAINTAINERS does
>  not exist anymore. I created the diff against the Linus tree.

Applied, but we're long overdue for an across-the-board-available
endianness Kconfig option that can flat out be used in these situations.
The current way this is handled is at best, a mess.
