From: David Miller <davem@davemloft.net>
Subject: Re: [2.6.37-rc5] Build error on parisc.
Date: Wed, 15 Dec 2010 10:19:25 -0800 (PST)
Message-ID: <20101215.101925.71116399.davem@davemloft.net>
References: <201012150801.oBF81EVm047830@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35660
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754512Ab0LOSS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 13:18:57 -0500
In-Reply-To: <201012150801.oBF81EVm047830@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 15 Dec 2010 17:01:14 +0900

> [2.6.37-rc5] Build error on parisc.
> 
> Commit 5635c10d "net: make sure struct dst_entry refcount is aligned on 64 bytes"
> uses manual padding. I triggered BUILD_BUG_ON() when using
> http://kernel.org/pub/tools/crosstool/files/bin/i686/4.5.1/i686-gcc-4.5.1-nolibc_hppa64-linux.tar.bz2 .
> 
>   make -s CROSS_COMPILE=hppa64-linux- ARCH=parisc
> 
>   include/net/dst.h: In function 'dst_hold':
>   include/net/dst.h:161:2: error: negative width in bit-field '<anonymous>'
> 
> I think below patch can fix the error but that commit says that we cannot use
> __atribute((aligned)). Why?

We don't want to create holes of unused space in the structure, we want
to know exactly how every byte of space is being used so nothing is
wasted when all features are enabed.
