From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] fix use after free in netlink_kernel_create()
Date: Sun, 13 Aug 2006 13:52:58 +0200
Message-ID: <44DF129A.6060607@trash.net>
References: <20060813101535.GA8703@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48568 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751000AbWHMLw5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 07:52:57 -0400
To: Akinobu Mita <mita@miraclelinux.com>
In-Reply-To: <20060813101535.GA8703@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Akinobu Mita wrote:
> This patch invalidates nl_table by setting NULL when netlink
> initialization failed. Otherwise netlink_kernel_create() would
> access nl_table which has already been freed.


Quite a few users of netlink_kernel_create will panic when creating
the socket fails (rtnetlink for example, which is always present),
so you might as well call panic here directly.

