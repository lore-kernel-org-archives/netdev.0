From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: Get rid of /proc/sys/net/unix/max_dgram_qlen
Date: Wed, 23 Aug 2006 00:19:08 +0200 (CEST)
Message-ID: <3794.81.207.0.53.1156285148.squirrel@81.207.0.53>
References: <4550.81.207.0.53.1156275903.squirrel@81.207.0.53>
    <20060822203914.GA9246@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helium.samage.net ([83.149.67.129]:1413 "EHLO helium.samage.net")
	by vger.kernel.org with ESMTP id S1751309AbWHVWTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 18:19:39 -0400
In-Reply-To: <20060822203914.GA9246@ms2.inr.ac.ru>
To: "Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, August 22, 2006 22:39, Alexey Kuznetsov said:
> Feel free to do this correctly. :-)
> Deleting "wrong" code rarely helps.
>
> It is the only protection of commiting infinite amount of memory to a socket.

Doesn't the "if (atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf)" check in sock_alloc_send_pskb()
limit things already? Or don't unix datagram sockets have a limited sendbuffer? Ouch, that
complicates things.

But wait a moment, I'm running a kernel now with the patch applied and some testcode shows that
everything seems to behave as expected, with send() returning EAGAIN after a while, and poll
giving POLLOUT when more data can be send.

What am I missing?

Indan


