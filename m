From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH 2/2] socket: add minimum listen queue length sysctl
Date: Sat, 26 Mar 2011 00:51:01 +0100
Message-ID: <20110325235101.GA2641@hell>
References: <1301077899-16482-1-git-send-email-hagen@jauu.net>
 <1301077899-16482-2-git-send-email-hagen@jauu.net>
 <1301084677.13505.26.camel@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:44115 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751753Ab1CYXvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 19:51:05 -0400
Content-Disposition: inline
In-Reply-To: <1301084677.13505.26.camel@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Rick Jones | 2011-03-25 13:24:37 [-0700]:

Hello Rick

>Well, one could LD_PRELOAD something that intercepted listen() calls no?

Noes, for dynamically linked programs yes, for statically linked ones no.

Furthermore, for distribution shipped programs an administrator would not
alter the init script or something. Editing /etc/sysctl.conf is as simple
as ...


>Is there already a similar minimum the admin can configure when the
>applications makes "too small" an explicit setsockopt() call against
>SO_SNDBUF or SO_RCVBUF?

net.ipv4.tcp_rmem, net.ipv4.tcp_mem, net.core.rmem_default, ...?

IMHO, _if_ a programmer modifies the send or receive buffer he _knows_ exactly
why. If he does not modify the buffer it is fine too, because _we_ tune the
buffers as good as we can - and we are good in this.

But, the backlog is different. Often the programmer does _not_ know how to
tune this variable. And, often the backlog depends on the target system, on
the network characteristic and the like.

Therefore we provide the system administrator the _ability_ to tune the actual
backlog.


Hagen
