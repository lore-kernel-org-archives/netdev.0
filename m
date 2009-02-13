From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 4 bytes kernel memory disclosure in SO_BSDCOMPAT gsopt
 try #2
Date: Thu, 12 Feb 2009 16:59:24 -0800 (PST)
Message-ID: <20090212.165924.220333032.davem@davemloft.net>
References: <20090212123545.GA46788@clem1.netasq.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clement.lecigne@netasq.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48522
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752010AbZBMA7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:59:30 -0500
In-Reply-To: <20090212123545.GA46788@clem1.netasq.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Clement LECIGNE <clement.lecigne@netasq.com>
Date: Thu, 12 Feb 2009 13:35:45 +0100

> In function sock_getsockopt() located in net/core/sock.c, optval v.val
> is not correctly initialized and directly returned in userland in case
> we have SO_BSDCOMPAT option set.
> 
> This dummy code should trigger the bug:
> 
> int main(void)
> {
> 	unsigned char buf[4] = { 0, 0, 0, 0 };
> 	int len;
> 	int sock;
> 	sock = socket(33, 2, 2);
> 	getsockopt(sock, 1, SO_BSDCOMPAT, &buf, &len);
> 	printf("%x%x%x%x\n", buf[0], buf[1], buf[2], buf[3]);
> 	close(sock);
> }
> 
> Here is a patch that fix this bug by initalizing v.val just after its declaration.

Applied, thank you.
