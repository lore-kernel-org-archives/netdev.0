From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [Bug 16494] NFS client over TCP hangs due to packet
 loss
Date: Tue, 03 Aug 2010 01:21:44 -0700 (PDT)
Message-ID: <20100803.012144.267950450.davem@davemloft.net>
References: <4c57cfe8.887b0e0a.2f79.4772@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com,
	William.Allen.Simpson@gmail.com, gilad@codefidence.com,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: andyc.bluearc@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4c57cfe8.887b0e0a.2f79.4772@mx.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Andy Chittenden" <andyc.bluearc@gmail.com>
Date: Tue, 3 Aug 2010 09:14:31 +0100

> I don't know whether this patch is the correct fix or not but it enables the
> NFS client to recover.
> 
> Kernel version: 2.6.34.1 and 2.6.32.
> 
> Fixes <https://bugzilla.kernel.org/show_bug.cgi?id=16494>. It clears down
> any previous shutdown attempts so that reconnects on a socket that's been
> shutdown leave the socket in a usable state (otherwise tcp_sendmsg() returns
> -EPIPE).

If the SunRPC code wants to close a TCP socket then use it again,
it should disconnect by doing a connect() with sa_family == AF_UNSPEC
