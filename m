From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2/2] socket: add minimum listen queue length sysctl
Date: Fri, 25 Mar 2011 13:24:37 -0700
Message-ID: <1301084677.13505.26.camel@tardy>
References: <1301077899-16482-1-git-send-email-hagen@jauu.net>
	 <1301077899-16482-2-git-send-email-hagen@jauu.net>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:35441 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751682Ab1CYUYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 16:24:42 -0400
In-Reply-To: <1301077899-16482-2-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-25 at 19:31 +0100, Hagen Paul Pfeifer wrote:
> In the case that a server programmer misjudge network characteristic the
> backlog parameter for listen(2) may not adequate to utilize hosts
> capabilities and lead to unrequired SYN retransmission - thus a
> underestimated backlog value can form an artificial limitation.
> 
> A listen queue length of 8 is often a way to small, but several
> server authors does not about know this limitation (from Erics server
> setup):
> 
> ss -a | head
> State      Recv-Q Send-Q      Local Address:Port          Peer
> Address:Port
> LISTEN     0      8                       *:imaps                    *:*
> LISTEN     0      8                       *:pop3s                    *:*
> LISTEN     0      50                      *:mysql                    *:*
> LISTEN     0      8                       *:pop3                     *:*
> LISTEN     0      8                       *:imap2                    *:*
> LISTEN     0      511                     *:www                      *:*
> 
> Until now it was not possible for the system (network) administrator to
> increase this value. A bug report must be filled, the backlog increased,
> a new version released or even worse: if using closed source software
> you cannot make anything.

Well, one could LD_PRELOAD something that intercepted listen() calls no?

> sysctl_min_syn_backlog provides the ability to increase the minimum
> queue length.

Is there already a similar minimum the admin can configure when the
applications makes "too small" an explicit setsockopt() call against
SO_SNDBUF or SO_RCVBUF?

rick jones

