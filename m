From: Tom Herbert <therbert@google.com>
Subject: Re: root_lock vs. device's TX lock
Date: Thu, 17 Nov 2011 16:35:34 -0800
Message-ID: <CA+mtBx8KfVQYcZFCJrQF__LJh7e0cRSPqSk1nn537Z_ATMjD9Q@mail.gmail.com>
References: <CA+mtBx8sHDprEct3zgGXXKEESK6i0FYnFS-_z35FOyVQjS9R4Q@mail.gmail.com>
	<1321547698.2751.68.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321550786.2751.83.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw6VfGKAk_gBZOjyCCcR0tCSc8PMjOoPv6Qi8m+P1idp4Q@mail.gmail.com>
	<CAKWjMd7xvepSb2sMf4X4U4cjRYizq=tP2TTHhYaozuyBeSW4AQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dave Taht <dave.taht@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:54154 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088Ab1KRAff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 19:35:35 -0500
Received: by ggnb2 with SMTP id b2so1844234ggn.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 16:35:35 -0800 (PST)
In-Reply-To: <CAKWjMd7xvepSb2sMf4X4U4cjRYizq=tP2TTHhYaozuyBeSW4AQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Actually, I'm interested in circumventing *both* locks. Our SoC has
> some quite-versatile queueing infrastructure, such that (for many
> queueing setups) we can do all of the queueing in hardware, using
> per-cpu access portals. By hacking around the qdisc lock, and using a
> tx queue per core, we were able to achieve a significant speedup.
>
This was actually one of the motivations for my question.  If we have
a one TX queue per core, and and use a trivial mq aware qdisc for
instance, the locking becomes mostly overhead.  I don't mind taking a
lock once per TX, but right now were taking three! (root lock twice,
and device lock once).

Even without one queue per TX, I think the overhead savings may still
be present.  Eric, I realize that a point of dropping the root lock in
sch_direct_xmit is to possibly allow queuing to to qdisc and device
xmit in parallel, but if you're using a trivial qdisc then the time in
qdisc may be << time in device xmit, so the overhead of locking could
mitigate the gains in parallelism.  At the very least, this benefit is
hugely variable depending on the qdisc used.

Tom
