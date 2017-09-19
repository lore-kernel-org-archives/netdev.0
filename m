From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH,net-next,0/2] Improve code coverage of syzkaller
Date: Tue, 19 Sep 2017 16:01:34 -0700 (PDT)
Message-ID: <20170919.160134.534837308168786965.davem@davemloft.net>
References: <20170919073402.2292-1-peterpenkov96@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peterpenkov96@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49918 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751606AbdISXBf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:01:35 -0400
In-Reply-To: <20170919073402.2292-1-peterpenkov96@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petar Penkov <peterpenkov96@gmail.com>
Date: Tue, 19 Sep 2017 00:34:00 -0700

> The following patches address this by providing the user(syzkaller)
> with the ability to send via napi_gro_receive() and napi_gro_frags().
> Additionally, syzkaller can specify how many fragments there are and
> how much data per fragment there is. This is done by exploiting the
> convenient structure of iovecs. Finally, this patch series adds
> support for exercising the flow dissector during fuzzing.
> 
> The code path including napi_gro_receive() can be enabled via the
> CONFIG_TUN_NAPI compile-time flag, and can be used by users other than
> syzkaller. The remainder of the changes in this patch series give the
> user significantly more control over packets entering the kernel. To
> avoid potential security vulnerabilities, hide the ability to send
> custom skbs and the flow dissector code paths behind a run-time flag
> IFF_NAPI_FRAGS that is advertised and accepted only if CONFIG_TUN_NAPI
> is enabled.
> 
> The patch series will be followed with changes to packetdrill, where
> these additions to the TUN driver are exercised and demonstrated.
> This will give the ability to write regression tests for specific
> parts of the early networking stack.
> 
> Patch 1/ Add NAPI struct per receive queue, enable NAPI, and use
> 	 napi_gro_receive() 
> Patch 2/ Use NAPI skb and napi_gro_frags(), exercise flow
> 	 dissector, and allow custom skbs.

I'm happy with everything except the TUN_NAPI Kconfig knob
requirement.

Rebuilding something just to test things isn't going to fly very well.

Please make it secure somehow, enable this stuff by default.

Thanks.
