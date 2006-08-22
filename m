From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: Get rid of /proc/sys/net/unix/max_dgram_qlen
Date: Wed, 23 Aug 2006 00:54:00 +0200 (CEST)
Message-ID: <1727.81.207.0.53.1156287240.squirrel@81.207.0.53>
References: <4550.81.207.0.53.1156275903.squirrel@81.207.0.53>
    <20060822203914.GA9246@ms2.inr.ac.ru>
    <3794.81.207.0.53.1156285148.squirrel@81.207.0.53>
    <20060822223402.GA16459@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helium.samage.net ([83.149.67.129]:60304 "EHLO
	helium.samage.net") by vger.kernel.org with ESMTP id S1750926AbWHVWya
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 18:54:30 -0400
In-Reply-To: <20060822223402.GA16459@ms2.inr.ac.ru>
To: "Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, August 23, 2006 0:34, Alexey Kuznetsov said:
>> > It is the only protection of commiting infinite amount of memory to a socket.
>>
>> Doesn't the "if (atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf)" check in
>> sock_alloc_send_pskb()
>> limit things already?
>
> Unfortunately, it does not. You can open a socket, send
> something to a selected victim, close it, and repeat this
> until receiver accumulates enough of skbs to kill the system.

Well, it seems the devil is in the details, as usual.

Isn't a socket freed until all skb are handled? In which case the limit on the number of open
files limits the total memory usage? (Same as with streaming sockets?)

Greetings,

Indan


