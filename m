From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v7 0/4] Support administratively closing application
 sockets
Date: Wed, 16 Dec 2015 07:43:34 -0800
Message-ID: <20151216074334.593a1ad6@xeon-e3>
References: <1450236605-87170-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	hannes@stressinduktion.org, eric.dumazet@gmail.com, ek@google.com,
	tom@herbertland.com, zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33679 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbbLPPna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 10:43:30 -0500
Received: by mail-pf0-f169.google.com with SMTP id e66so14302954pfe.0
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 07:43:30 -0800 (PST)
In-Reply-To: <1450236605-87170-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Dec 2015 12:30:01 +0900
Lorenzo Colitti <lorenzo@google.com> wrote:

> This patchset adds the ability to administratively close a socket
> without any action from the process owning the socket or the
> socket protocol.
> 
> It implements this by adding a new diag_destroy function pointer
> to struct proto. In-kernel callers can access this functionality
> directly by calling sk->sk_prot->diag_destroy(sk, err).
> 
> It also exposes this functionality to userspace via a new
> SOCK_DESTROY operation in the NETLINK_SOCK_DIAG sockets. This
> allows a privileged userspace process, such as a connection
> manager or system administration tool, to close sockets belonging
> to other apps when the network they were established on has
> disconnected. It is needed on laptops and mobile hosts to ensure
> that network switches / disconnects do not result in applications
> being blocked for long periods of time (minutes) in read or
> connect calls on TCP sockets that will never succeed because the
> IP address they are bound to is no longer on the system. Closing
> the sockets causes these calls to fail fast and allows the apps
> to reconnect on another network.
> 
> Userspace intervention is necessary because in many cases the
> kernel does not have enough information to know that a connection
> is now inoperable. The kernel can know if a packet can't be
> routed, but in general it won't know if a TCP connection is stuck
> because it is now routed to a network where its source address is
> no longer valid [5][6].


I see no security checks in the diag infrastructure.
Up until now diag has been read-only access and therefore has been
allowed for all users.
