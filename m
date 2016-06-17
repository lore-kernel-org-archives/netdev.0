From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH resend] net: sock: Add option for memory optimized hints.
Date: Fri, 17 Jun 2016 09:07:02 -0700
Message-ID: <1466179622.7945.216.camel@edumazet-glaptop3.roam.corp.google.com>
References: <57640204.9070300@sonymobile.com>
	 <1466172860.7945.212.camel@edumazet-glaptop3.roam.corp.google.com>
	 <57640BA7.8010304@sonymobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "open list:PTP HARDWARE CLOCK SUPPORT" <netdev@vger.kernel.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34551 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268AbcFQQHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 12:07:09 -0400
Received: by mail-pf0-f196.google.com with SMTP id 66so6499835pfy.1
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 09:07:08 -0700 (PDT)
In-Reply-To: <57640BA7.8010304@sonymobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-06-17 at 16:39 +0200, peter enderborg wrote:

> It is mainly for af_unix sockets, and the effect is
> quite significant when you hit a compaction, or with
> this patch avoid get in to compaction, but it
> can also be used for reducing the pressure on memory
> for tcp.

BTW, TCP always attempt order-3 allocations, even if you do a write(fd,
buffer, 4000)


So really your patch wont help.

We need to fix the mm layer (if needed), not add various works around.
