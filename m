From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: allow effective reduction of TCP's rcv-buffer via
 setsockopt
Date: Sun, 22 Aug 2010 21:44:28 -0700 (PDT)
Message-ID: <20100822.214428.52175315.davem@davemloft.net>
References: <1282235585-14206-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, eric.dumazet@gmail.com,
	ilpo.jarvinen@helsinki.fi
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53037
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753200Ab0HWEoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 00:44:11 -0400
In-Reply-To: <1282235585-14206-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Thu, 19 Aug 2010 18:33:05 +0200

> Via setsockopt it is possible to reduce the socket RX buffer
> (SO_RCVBUF). TCP method to select the initial window and window scaling
> option in tcp_select_initial_window() currently misbehaves and do not
> consider a reduced RX socket buffer via setsockopt.
> 
> Even though the server's RX buffer is reduced via setsockopt() to 256
> byte (Initial Window 384 byte => 256 * 2 - (256 * 2 / 4)) the window
> scale option is still 7:
> 
> 192.168.1.38.40676 > 78.47.222.210.5001: Flags [S], seq 2577214362, win 5840, options [mss 1460,sackOK,TS val 338417 ecr 0,nop,wscale 0], length 0
> 78.47.222.210.5001 > 192.168.1.38.40676: Flags [S.], seq 1570631029, ack 2577214363, win 384, options [mss 1452,sackOK,TS val 2435248895 ecr 338417,nop,wscale 7], length 0
> 192.168.1.38.40676 > 78.47.222.210.5001: Flags [.], ack 1, win 5840, options [nop,nop,TS val 338421 ecr 2435248895], length 0
> 
> Within tcp_select_initial_window() the original space argument - a
> representation of the rx buffer size - is expanded during
> tcp_select_initial_window(). Only sysctl_tcp_rmem[2], sysctl_rmem_max
> and window_clamp are considered to calculate the initial window.
> 
> This patch adjust the window_clamp argument if the user explicitly
> reduce the receive buffer.
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Applied, thanks.
