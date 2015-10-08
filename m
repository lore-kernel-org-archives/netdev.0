From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/4] net: SO_INCOMING_CPU setsockopt() support
Date: Thu, 8 Oct 2015 10:10:11 -0700
Message-ID: <CALx6S37Dd0iWo7q1KP+yGSVEb8CScj788mJZpo-8-+6MwV7DMw@mail.gmail.com>
References: <1444318627-27883-1-git-send-email-edumazet@google.com>
	<1444318627-27883-2-git-send-email-edumazet@google.com>
	<CALx6S35jNA8sQ_yibFK-eL-asbNP9BieRvTcKkM3-CNarKJMDA@mail.gmail.com>
	<1444321775.27760.19.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34ctcycnjTR4gon7oSRMdh3Xod2yi_B_TtTvrxt6MW4gg@mail.gmail.com>
	<1444323627.27760.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34920 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964921AbbJHRKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 13:10:13 -0400
Received: by ioiz6 with SMTP id z6so65008870ioi.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 10:10:13 -0700 (PDT)
In-Reply-To: <1444323627.27760.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 10:00 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-10-08 at 09:44 -0700, Tom Herbert wrote:
>
>> I see. We are not using SO_INCOMING_CPU_MASK as a defense against
>> DDOS. It's used ensure affinity in application connection processing
>> between CPUs. For instance, if we have two NUMA nodes we can start two
>> instances of the application bound to each node and then use
>> SO_REUSEPORT and SO_INCOMING_CPU_MASK to ensure connections are
>> processed on the the same NUMA node. Packets crossing NUMA boundaries
>> even with RFS is painful.
>
> Then maybe you need something simpler than a mask of cpus, like
> SO_INCOMING_NODE ?
>
> Note that this could also be automatically tuned.
>
> If you have a bunch of listeners on one port (could be 2), then the
> underlying node on which TCP socket was allocated could be used as a
> score modifier in compute_score()
>
Maybe, but I really like the simplicity of SO_INCOMING_CPU_MASK in
that it doesn't depend on NUMA configuration or RSS configuration.
It's very easy for the application to just set the same incoming CPU
mask to be the same CPU mask that the listener thread is bound to.
We've seen some nice performance benefits in doing with memcached,
that is to run an instances bound to the set of CPUs for each set NUMA
node and bind listener threads to the same set.

Tom

>
