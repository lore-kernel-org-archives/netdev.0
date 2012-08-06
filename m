From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] net: Don't use ifindices in hash fns
Date: Mon, 06 Aug 2012 13:51:57 +0200
Message-ID: <1344253917.26674.13.camel@edumazet-glaptop>
References: <501F9CAF.3030605@parallels.com>
	 <501F9CDA.6040403@parallels.com>
	 <1344249789.26674.8.camel@edumazet-glaptop>
	 <501FA3FA.9010107@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57603 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755998Ab2HFLwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 07:52:02 -0400
Received: by bkwj10 with SMTP id j10so989343bkw.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 04:52:00 -0700 (PDT)
In-Reply-To: <501FA3FA.9010107@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 15:01 +0400, Pavel Emelyanov wrote:

> Damn :( You're right.
> 
> > This returns 0 as is
> 
> Well, on 64-bit no, but what it does is also not what it was supposed to.
> 

Here, my L1_CACHE_BYTES is 64, but whatever

> > I would define a generic pointer hash mix instead of a 'net_device
> > thing'
> > 
> > static inline u32 ptr_hash_mix(void *ptr)
> > {
> > #if BITS_PER_LONG==32
> > 	return (u32)(unsigned long)ptr;
> > #else
> > 	return (u32)((unsigned long)ptr >> L1_CACHE_SHIFT);
> > #endif
> > }
> 
> OK. It will also obsolete the net_hash_mix then. Any suggestions where to put
> the new one?

Not obsolete net_hash_mix(), since this one can return 0 if
CONFIG_NET_NS is not set.

static inline unsigned int net_hash_mix(struct net *net)
{
#ifdef CONFIG_NET_NS
	return ptr_hash_mix(net);
#else
	return 0;
#endif
}

I dont know, you could add this to include/linux/hash.h
