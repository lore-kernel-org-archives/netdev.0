From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] veth: remove hardware checksum feature
Date: Thu, 08 Aug 2013 13:16:54 -0700
Message-ID: <1375993014.4004.112.camel@edumazet-glaptop>
References: <51F15E50.8080208@guap.ru> <5202E153.4060202@candelatech.com>
	   <1375920752.4004.71.camel@edumazet-glaptop>
	   <5202E510.9060309@candelatech.com>
	  <1375924125.4004.83.camel@edumazet-glaptop>
	  <5202FA51.4040906@candelatech.com>
	 <1375930325.4004.88.camel@edumazet-glaptop>
	 <5203F4E6.1010701@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:64535 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966368Ab3HHUQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 16:16:57 -0400
Received: by mail-ob0-f170.google.com with SMTP id eh20so578947obb.1
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 13:16:57 -0700 (PDT)
In-Reply-To: <5203F4E6.1010701@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-08 at 12:43 -0700, Ben Greear wrote:

> So, the question is:  Is there any time that I *should* be mucking with
> skb->ip_summed when bridging pkts from one device to another on modern
> kernels?  I'm using the ptype_all hook to grab packets, and ndo_start_xmit
> to send them, in case that matters.


ndo_start_xmit() is likely bypassing the core network fallbacks.

You might try dev_hard_start_xmit() instead
