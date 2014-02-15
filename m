From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: socket bind to local address ::ffff:127.0.0.1 question
Date: Sat, 15 Feb 2014 18:10:41 +0100
Message-ID: <20140215171041.GE8634@order.stressinduktion.org>
References: <CAK3+h2zzx5AocGeJxu9cW0kNkiRew6GNDMrbsNq-7H8co=T0_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57447 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753443AbaBORKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Feb 2014 12:10:43 -0500
Content-Disposition: inline
In-Reply-To: <CAK3+h2zzx5AocGeJxu9cW0kNkiRew6GNDMrbsNq-7H8co=T0_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 12:41:21PM -0800, Vincent Li wrote:
> we have a traffic path like <BIGIP monitor userland process on Linux>
> <------> router<------->pool/real server
> 
> there is a  weird issue that intermittently, a socket is bound to
> loopback address '::ffff:127.0.0.1' which caused issue for us because
> remote end host can't SYN+ACK the SYN source from 127.0.0.1, strace
> the userland process shows:
> 
> 6797  12:36:48.815296 connect(11, {sa_family=AF_INET6,
> sin6_port=htons(8180), inet_pton(AF_INET6, "::ffff:172.16.3.165",
> &sin6_addr), sin6_flowinfo=0, sin6_scope_id=875638834}, 28) = -1
> EINPROGRESS (Operation now in progress)

Have you checked the connect operation completed successfully in this
case? Error state would be interesting to see (SO_ERROR).

> 6797  12:36:48.815464 gettimeofday({1391744208, 815499}, NULL) = 0
> 6797  12:36:48.815552 time(NULL)        = 1391744208
> 6797  12:36:48.815657 stat64("/etc/localtime", {st_mode=S_IFREG|0644,
> st_size=331, ...}) = 0
> ...................
> 6797  12:36:48.816948 getsockname(11, {sa_family=AF_INET6,
> sin6_port=htons(45621), inet_pton(AF_INET6, "::ffff:127.0.0.1",
> &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
> [18433145657494601756]) = 0
   ^^^
Urks!

What kernel version are you using?

Do you have a reproducer, sample code in C where this problem sometimes
happens or could you expand the strace listings a bit (maybe setsockopts,
bindv6only settings)?

Also you seem to not initialize your struct sockaddr_in6 given to connect, as
the sin6_scope_id seems bogus (uninitialized memory?). But should not
matter with v4mapped addresses though.

Greetings,

  Hannes
