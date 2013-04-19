From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rps: selective flow shedding during softnet overflow
Date: Fri, 19 Apr 2013 12:21:40 -0700
Message-ID: <1366399300.16391.49.camel@edumazet-glaptop>
References: <1366393612-16885-1-git-send-email-willemb@google.com>
	 <20130419120303.222927c9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:39777 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753394Ab3DSTVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 15:21:43 -0400
Received: by mail-da0-f43.google.com with SMTP id u36so2080184dak.2
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 12:21:42 -0700 (PDT)
In-Reply-To: <20130419120303.222927c9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 12:03 -0700, Stephen Hemminger wrote:

> The netdev_backlog only applies for RPS and non-NAPI devices.
> So this won't help if receive packet steering is not enabled.

Yes, the point is exactly using RPS as a proxy to control
the behavior and better distribute the load.

> Seems like a deficiency in the receive steering design rather
> than the netdev_backlog.

Well, RPS works well, even for multiqueue NICS. But nobody said it was
perfect.

Back to NAPI (without RPS) :

If one RX queue (multiqueue device or not) is hit by a single flow, how
do you plan to do anything, since without RPS we process each packet
after another.

There is no queue building up in our stack. (Only queue is in the NIC RX
ring). Eventually NIC drops packets.

> 
> Can't you do this with existing ingress stuff?

ingress is not yet multiqueue enabled, AFAIK.

Expect very poor performance from it.

> The trend seems to be put in more fixed infrastructure to deal with
> performance and server problems rather than building general purpose
> solutions.

OK, I see you want to push netmap. Lets talk about general purpose
solutions.
