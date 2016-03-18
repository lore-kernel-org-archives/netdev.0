From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: closed SOCK_SEQPACKET socketpair must get
 SIGPIPE
Date: Fri, 18 Mar 2016 18:32:30 -0400 (EDT)
Message-ID: <20160318.183230.1601751551897264970.davem@davemloft.net>
References: <1458032624-139688-1-git-send-email-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, rweikusat@mobileactivedefense.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458032624-139688-1-git-send-email-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Tue, 15 Mar 2016 10:03:44 +0100

> According to IEEE Std 1003.1, 2013, sending data to a SOCK_SEQPACKET
> socketpair with MSG_NOSIGNAL flag set must result in a SIGPIPE if the
> socket is no longer connected.
> 
> I used the following program to check the kernel behavior:
 ...
> Signed-off-by: Alexander Potapenko <glider@google.com>

In the final analysis I don't think we can do this.

Properly working programs will start to mysteriously receive
signals in this situation and fail.

I'm sorry but I think we're stuck with this behavior.
