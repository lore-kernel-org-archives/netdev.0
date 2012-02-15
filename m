From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Re: Re: Re: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 15 Feb 2012 09:49:07 -0500
Message-ID: <CADVnQymT6saSSmUmT7BUShfQFoJ+u4JMQ=F2bhRv4vB_Pzj=9Q@mail.gmail.com>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	<4249109.nLB9JCi9YF@localhost.localdomain>
	<1329313785.2437.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<2687521.3ztN17SHUf@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:36564 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756157Ab2BOOtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 09:49:08 -0500
Received: by qadc10 with SMTP id c10so3139799qad.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 06:49:08 -0800 (PST)
In-Reply-To: <2687521.3ztN17SHUf@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there was an increase in the number of bytes charged to the socket
for each skb, without a corresponding increase in TCP receive buffer
size, that would explain a systematic decrease in receiver window that
would cause some paths, like perhaps these, to become
receiver-window-limited (which is consistent with the symptom of
stable bandwidth for a given path).

Can you please try increasing the default TCP receiver window to see
if this helps; try this as root on the 3.2 machine:

sysctl net.ipv4.tcp_rmem="4096 897664 897664"

Basically making the middle number as big as the third number should
bump up the default receiver window size.

neal
