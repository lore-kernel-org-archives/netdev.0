From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Sun, 18 Jul 2010 14:25:50 -0700 (PDT)
Message-ID: <20100718.142550.25115105.davem@davemloft.net>
References: <201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp>
	<1279441990.2476.26.camel@edumazet-laptop>
	<201007181949.IFC00070.OMHQVSFOLJFFOt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	paul.moore@hp.com, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53107
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757308Ab0GRVZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 17:25:34 -0400
In-Reply-To: <201007181949.IFC00070.OMHQVSFOLJFFOt@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 18 Jul 2010 19:49:11 +0900

> Eric Dumazet wrote:
>> I read this patch and could not find out if an SNMP counter was
>> increased in the case a frame was not delivered but dropped in kernel
>> land.
> 
> UDP_MIB_INDATAGRAMS and UDP_MIB_INERRORS will not be increased
> if dropped by security_socket_post_recvmsg()'s decision.
> Should we increment UDP_MIB_INDATAGRAMS and/or UDP_MIB_INERRORS?

This decision should be guided by what we do for in the case
of the other existing security hooks.

I don't think it makes any sense to make the post recvmsg() hook
behave any differently from the existing hooks in this regard.
