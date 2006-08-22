From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Get rid of /proc/sys/net/unix/max_dgram_qlen
Date: Wed, 23 Aug 2006 02:34:02 +0400
Message-ID: <20060822223402.GA16459@ms2.inr.ac.ru>
References: <4550.81.207.0.53.1156275903.squirrel@81.207.0.53> <20060822203914.GA9246@ms2.inr.ac.ru> <3794.81.207.0.53.1156285148.squirrel@81.207.0.53>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:34199 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751334AbWHVWeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 18:34:02 -0400
To: Indan Zupancic <indan@nul.nu>
Content-Disposition: inline
In-Reply-To: <3794.81.207.0.53.1156285148.squirrel@81.207.0.53>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> > It is the only protection of commiting infinite amount of memory to a socket.
> 
> Doesn't the "if (atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf)" check in sock_alloc_send_pskb()
> limit things already?

Unfortunately, it does not. You can open a socket, send
something to a selected victim, close it, and repeat this
until receiver accumulates enough of skbs to kill the system.

Alexey
