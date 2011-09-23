From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: change capability used by socket options IP{,V6}_TRANSPARENT
Date: Fri, 23 Sep 2011 12:33:43 -0700
Message-ID: <CAHo-OozcFULbDBHoWsQPoun-HAaHLBM=pRzMJjsv1cJF77zSYg@mail.gmail.com>
References: <1315927629.5851.4.camel@bzorp>
	<1316734189-26668-1-git-send-email-zenczykowski@gmail.com>
	<4E7CB5A9.2020303@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	James Morris <jmorris@namei.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:38216 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687Ab1IWTdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 15:33:43 -0400
In-Reply-To: <4E7CB5A9.2020303@schaufler-ca.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Under what circumstances would a process that requires the
> new capability not require CAP_NET_ADMIN? Is there a real
> case where a process would be expected to require only this
> new capability? Adding new capability values is somewhat
> perilous and the granularity you are proposing, that of
> controlling a single bit, would explode the list of
> capabilities into the hundreds if it were applied throughout
> the kernel.

CAP_NET_ADMIN is a huge hammer, it allows one to totally
reconfigure the networking subsystem.

In a containerized multi-user/job environment, you do not want
something like an instance of a load-balanced web server, proxy
or dns server being able to do that - policy/configuration decisions
should be left up to the administrator and/or machine management
daemon(s).  Each of these can make use of transparent sockets
(in various ways, mostly in coordination with large scale load balancing).

You also do not want one user running in one container being able
to sniff (CAP_NET_RAW) traffic from another user (hence CAP_NET_RAW
isn't an acceptable substitute).

One could conceivably use network namespaces for seperation, but
in this particular case they are _way_ too overkill (and also add too
much overhead).

This might be *just* a single bit in the socket, but this bit effectively
controls whether you can do certain types of privileged operations
on the socket in question - and it gets tested in various places throughout
the networking stack.

Hopefully, this answers your question.

- Maciej
