From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Can I limit the number of active tx per TCP socket?
Date: Fri, 07 Mar 2014 07:00:02 -0800
Message-ID: <1394204402.20149.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6D3B91@AcuExch.aculab.com>
	 <5318ADB1.5050107@hp.com>
	 <CADVnQyn1+WRqS9HQmMn9JgpBz0Wajg=40yVhdyqv_AAo4tpWUA@mail.gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6D727E@AcuExch.aculab.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6D755C@AcuExch.aculab.com>
	 <1394202127.20149.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6D7699@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Neal Cardwell' <ncardwell@google.com>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:42237 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860AbaCGPAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 10:00:06 -0500
Received: by mail-pa0-f49.google.com with SMTP id lj1so4232897pab.22
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 07:00:05 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6D7699@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-07 at 14:35 +0000, David Laight wrote:

> Only the one connection between the two IP addresses is carrying this data.
> Other connections carry other traffic that has entirely different
> characteristics.

You can adapt the filter to match _this_ connection.

Other traffic will just use a different path (other qdisc if you prefer)

You can match things like source port, destination port, or fw marks
(using iptables or a socket option)

By letting the stack doing optimal aggregation, you'll have no overhead
an perfect pacing (using high resolution timer)

fq has the maxrate parameter so that you can avoid using
SO_MAX_PACING_RATE in the application.

By shaping the flow, you'll allow TCP stack to build efficient packets,
because tcp_sendmsg() will append data to the last skb in write queue,
thanks to auto corking.
