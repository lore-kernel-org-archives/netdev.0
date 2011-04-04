From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v3] net: Allow no-cache copy from user on transmit
Date: Mon, 4 Apr 2011 08:10:08 -0700
Message-ID: <BANLkTik__2JSNHXf4JBDqQPgDmMgsT9Lug@mail.gmail.com>
References: <alpine.DEB.2.00.1104032136540.5452@pokey.mtv.corp.google.com>
	<20110403.220305.71570981.davem@davemloft.net>
	<20110403.222341.149838774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:37726 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754269Ab1DDPKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 11:10:12 -0400
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p34FABo9021980
	for <netdev@vger.kernel.org>; Mon, 4 Apr 2011 08:10:11 -0700
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by hpaq1.eem.corp.google.com with ESMTP id p34FA86k012677
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 4 Apr 2011 08:10:10 -0700
Received: by pwi10 with SMTP id 10so1535307pwi.28
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2011 08:10:08 -0700 (PDT)
In-Reply-To: <20110403.222341.149838774.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Actually, I'm sorry, I have to kick this back to you again Tom.
>
I don't think I see the problem.  Does this still fail sparc compilation?

> The original problem is that "linux/uaccess.h" has not been included
> in the spot where you try to invoke the nocache copies.
>
So I added include of linux/uaccess.h to net/sock.h.

> linux/uaccess.h, when ARCH_HAS_NOCACHE_UACCESS is defined, provides
> dummy routines.
>
I assume you mean "is not defined"?

> So it's not correct to use ARCH_HAS_NOCACHE_UACCESS to conditionalize
> things in the networking, just make sure linux/uaccess.h is included
> at the call sites.
>
Why isn't this correct?  Shouldn't it be okay if linux/uaccess.h
(asm/uaccess.h) is always included where  ARCH_HAS_NOCACHE_UACCESS is
used?
