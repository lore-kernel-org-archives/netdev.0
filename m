From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/packet: initialize val in packet_getsockopt()
Date: Tue, 25 Apr 2017 11:44:33 -0400 (EDT)
Message-ID: <20170425.114433.143144279134920277.davem@davemloft.net>
References: <20170424125914.43270-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: glider@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40976 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1950334AbdDYPof (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:44:35 -0400
In-Reply-To: <20170424125914.43270-1-glider@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Potapenko <glider@google.com>
Date: Mon, 24 Apr 2017 14:59:14 +0200

> In the case getsockopt() is called with PACKET_HDRLEN and optlen < 4
> |val| remains uninitialized and the syscall may behave differently
> depending on its value. This doesn't have security consequences (as the
> uninit bytes aren't copied back), but it's still cleaner to initialize
> |val| and ensure optlen is not less than sizeof(int).
> 
> This bug has been detected with KMSAN.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
> v2: - if len < sizeof(int), make it 0

No, you should signal an error if the len is too small.

Returning zero bytes to userspace silently makes the user think that
he got the data he asked for.
