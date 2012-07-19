From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 5/7] net-tcp: Fast Open client -
 sendmsg(MSG_FASTOPEN)
Date: Thu, 19 Jul 2012 19:59:16 +0200
Message-ID: <1342720756.2626.4654.camel@edumazet-glaptop>
References: <1342716191-19196-1-git-send-email-ycheng@google.com>
	 <1342716191-19196-6-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:49015 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab2GSR7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:59:23 -0400
Received: by vbbff1 with SMTP id ff1so2191752vbb.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 10:59:22 -0700 (PDT)
In-Reply-To: <1342716191-19196-6-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 09:43 -0700, Yuchung Cheng wrote:
> sendmsg() (or sendto()) with MSG_FASTOPEN is a combo of connect(2)
> and write(2). The application should replace connect() with it to
> send data in the opening SYN packet.
> 
> For blocking socket, sendmsg() blocks until all the data are buffered
> locally and the handshake is completed like connect() call. It
> returns similar errno like connect() if the TCP handshake fails.
> 
> For non-blocking socket, it returns the number of bytes queued (and
> transmitted in the SYN-data packet) if cookie is available. If cookie
> is not available, it transmits a data-less SYN packet with Fast Open
> cookie request option and returns -EINPROGRESS like connect().
> 
> Using MSG_FASTOPEN on connecting or connected socket will result in
> simlar errno like repeating connect() calls. Therefore the application
> should only use this flag on new sockets.
> 
> The buffer size of sendmsg() is independent of the MSS of the connection.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
