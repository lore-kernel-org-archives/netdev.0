From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: SO_INCOMING_CPU setsockopt() support
Date: Thu, 08 Oct 2015 10:00:27 -0700
Message-ID: <1444323627.27760.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444318627-27883-1-git-send-email-edumazet@google.com>
	 <1444318627-27883-2-git-send-email-edumazet@google.com>
	 <CALx6S35jNA8sQ_yibFK-eL-asbNP9BieRvTcKkM3-CNarKJMDA@mail.gmail.com>
	 <1444321775.27760.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34ctcycnjTR4gon7oSRMdh3Xod2yi_B_TtTvrxt6MW4gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36637 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933871AbbJHRA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 13:00:29 -0400
Received: by pablk4 with SMTP id lk4so59820152pab.3
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 10:00:29 -0700 (PDT)
In-Reply-To: <CALx6S34ctcycnjTR4gon7oSRMdh3Xod2yi_B_TtTvrxt6MW4gg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-08 at 09:44 -0700, Tom Herbert wrote:

> I see. We are not using SO_INCOMING_CPU_MASK as a defense against
> DDOS. It's used ensure affinity in application connection processing
> between CPUs. For instance, if we have two NUMA nodes we can start two
> instances of the application bound to each node and then use
> SO_REUSEPORT and SO_INCOMING_CPU_MASK to ensure connections are
> processed on the the same NUMA node. Packets crossing NUMA boundaries
> even with RFS is painful.

Then maybe you need something simpler than a mask of cpus, like
SO_INCOMING_NODE ?

Note that this could also be automatically tuned.

If you have a bunch of listeners on one port (could be 2), then the
underlying node on which TCP socket was allocated could be used as a
score modifier in compute_score()
