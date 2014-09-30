From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix getsockopt(SO_PEERNAME) buffer size against
 potential future buffer overflow
Date: Tue, 30 Sep 2014 00:59:25 -0400 (EDT)
Message-ID: <20140930.005925.995989898229686123.davem@davemloft.net>
References: <20140928135545.GA23220@type.youpi.perso.aquilenet.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: samuel.thibault@ens-lyon.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140928135545.GA23220@type.youpi.perso.aquilenet.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Date: Sun, 28 Sep 2014 15:55:45 +0200

> In net/core/sock.c's sock_getsockopt, the address buffer size is
> hardcoded to 128. It happens that sizeof(struct sockaddr_storage) is
> indeed 128, but that is just luck and would probably not get updated
> whenever sockaddr_storage would grow. This patch makes it simply use
> sockaddr_storage instead.
> 
> Signed-off-by:  Samuel Thibault <samuel.thibault@ens-lyon.org>

sockaddr_storage's size is a user exported API and therefore can
never, ever, change.

If you want to change 128 to _K_SS_MAXSIZE or similar, fine.
