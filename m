From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next 0/2] net: allow setting ecn via routing table
Date: Thu, 30 Oct 2014 16:05:42 -0700
Message-ID: <1414710342.15352.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414276729-17871-1-git-send-email-fw@strlen.de>
	 <20141028.165737.2009356944765978630.davem@davemloft.net>
	 <20141029122307.GA29253@breakpoint.cc>
	 <20141030.155958.156984068627586090.davem@davemloft.net>
	 <20141030205204.GE10069@breakpoint.cc>
	 <1414703260.15352.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141030221501.GA9416@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:33231 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161495AbaJ3XFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 19:05:44 -0400
Received: by mail-ig0-f173.google.com with SMTP id r10so4310914igi.6
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 16:05:43 -0700 (PDT)
In-Reply-To: <20141030221501.GA9416@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-30 at 23:15 +0100, Florian Westphal wrote:

> Do you think a fallback to non-ecn for retransmitted syns would help?
> If not, do you think having ecn tunable available via route is helpful?

Unfortunately some firewalls are buggy and accept a single SYN per flow.

You would need to blacklist ecn at first sign of a possible ecn problem,
for all following connections attempts.

Note that ECN problems are not only contained in SYN packets being
eventually dropped. You might have a success to establish a flow, and
later get CE marks for all packets and cwnd converges to 1.

This is really a lot of work to get all sorted out.
