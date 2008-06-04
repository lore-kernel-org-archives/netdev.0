From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] [RAW]: Raw socket leak.
Date: Wed, 04 Jun 2008 15:16:36 -0700 (PDT)
Message-ID: <20080604.151636.212578810.davem@davemloft.net>
References: <1212154985-28103-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41121
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762985AbYFDWQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 18:16:36 -0400
In-Reply-To: <1212154985-28103-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 30 May 2008 17:43:05 +0400

> The program below just leaks the raw kernel socket
> 
> int main() {
>         int fd = socket(PF_INET, SOCK_RAW, IPPROTO_UDP);
>         struct sockaddr_in addr;
> 
>         memset(&addr, 0, sizeof(addr));
>         inet_aton("127.0.0.1", &addr.sin_addr);
>         addr.sin_family = AF_INET;
>         addr.sin_port = htons(2048);
>         sendto(fd,  "a", 1, MSG_MORE, &addr, sizeof(addr));
>         return 0;
> }
> 
> Corked packet is allocated via sock_wmalloc which holds the owner socket,
> so one should uncork it and flush all pending data on close. Do this in the
> same way as in UDP.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Acked-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Applied, thanks Denis.
