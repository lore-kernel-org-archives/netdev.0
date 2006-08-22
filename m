From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: Get rid of /proc/sys/net/unix/max_dgram_qlen
Date: Wed, 23 Aug 2006 01:53:12 +0200 (CEST)
Message-ID: <3667.81.207.0.53.1156290792.squirrel@81.207.0.53>
References: <4550.81.207.0.53.1156275903.squirrel@81.207.0.53>
    <20060822203914.GA9246@ms2.inr.ac.ru>
    <3794.81.207.0.53.1156285148.squirrel@81.207.0.53>
    <20060822223402.GA16459@ms2.inr.ac.ru>
    <1727.81.207.0.53.1156287240.squirrel@81.207.0.53>
    <20060822233200.GA20104@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helium.samage.net ([83.149.67.129]:15497 "EHLO
	helium.samage.net") by vger.kernel.org with ESMTP id S1750713AbWHVXxn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 19:53:43 -0400
In-Reply-To: <20060822233200.GA20104@ms2.inr.ac.ru>
To: "Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, August 23, 2006 1:32, Alexey Kuznetsov said:

>> Isn't a socket freed until all skb are handled? In which case the limit on the number of open
>> files limits the total memory usage? (Same as with streaming sockets?)
>
> Alas. Number of closed sockets is not limited. Actually, it is limited
> by sk_max_ack_backlog*max_files, which is a lot.

Hmm... So setting sk_max_ack_backlog to 1 makes it limited by max_files,
which should make the worst case the same as for streaming sockets, right?

> The problem is specific for unconnected datagram sockets
> (predicate unix_peer(other) != sk)

Doesn't that mean that both sockets are connected to eachother? I mean,
if only this socket connects to the other the above check isn't true.

Greetings,

Indan


