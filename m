From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/packet: initialize val in packet_getsockopt()
Date: Thu, 20 Apr 2017 15:56:20 -0400 (EDT)
Message-ID: <20170420.155620.2005862240803164222.davem@davemloft.net>
References: <20170418174708.26341-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170418174708.26341-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Tue, 18 Apr 2017 19:47:08 +0200

> In the case getsockopt() is called with PACKET_HDRLEN and zero length,
> |val| remains uninitialized and the syscall may behave differently
> depending on its value. This doesn't have security consequences (as the
> uninit bytes aren't copied back), but it's still cleaner to initialize
> |val|.
> 
> This bug has been detected with KMSAN.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Copying into an 'int' only 1, 2, or 3 bytes is not going to work
properly.

Either enforce that it must be 4 bytes long, or handle the smaller
sizes properly such that it will work regardless of endianness.

Thanks.
