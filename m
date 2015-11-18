From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 11:12:18 +0100
Message-ID: <1447841538.833901.443067761.28637F38@webmail.messagingengine.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:59477 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754495AbbKRKMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 05:12:19 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id D0F6920BFB
	for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 05:12:18 -0500 (EST)
In-Reply-To: <1447811024-8553-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Nov 18, 2015, at 02:43, Lorenzo Colitti wrote:
> This patch series adds the ability for a privileged process to
> destroy sockets belonging to other userspace processes via the
> sock_diag interface, and implements that for TCP sockets.
> 
> This functionality is needed on laptops and mobile hosts to
> ensure that network switches / disconnects do not result in
> applications being blocked for long periods of time (minutes) in
> read or connect calls on TCP sockets that will never succeed
> because the IP address they are bound to is gone. Closing the
> sockets in the protocol layer causes these calls to fail fast and
> allows applications to reconnect on another network.

I regularly do this with gdb, connecting to the process, looking up the
filedescriptors in /proc/pid/fd and closing the socket. Actually it will
also be removed from the poll tables and thus unlocks the system. I
think a user space approach would be preferred to do so, or some out of
band signalling (which we actually already have in terms of netlink
monitor).

Bye,
Hannes
