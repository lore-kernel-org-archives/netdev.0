From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [PATCH] firewire: net: rate-limit log spam at transmit failure
Date: Mon, 08 Nov 2010 03:41:57 +0200
Message-ID: <1289180517.4318.3.camel@maxim-laptop>
References: <tkrat.01ca17fba0508ae0@s5r6.in-berlin.de>
	 <tkrat.1b9925fa1d199c23@s5r6.in-berlin.de>
	 <tkrat.18b9f67ac78dcbea@s5r6.in-berlin.de>
	 <tkrat.276aeae22ec60090@s5r6.in-berlin.de>
	 <1289100404.3277.28.camel@maxim-laptop>
	 <1289100737.3277.32.camel@maxim-laptop>
	 <4CD6957C.5030504@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59028 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab0KHBmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 20:42:07 -0500
Received: by fxm16 with SMTP id 16so3667223fxm.19
        for <netdev@vger.kernel.org>; Sun, 07 Nov 2010 17:42:02 -0800 (PST)
In-Reply-To: <4CD6957C.5030504@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-11-07 at 13:03 +0100, Stefan Richter wrote:
> Maxim Levitsky wrote:
> > I have here my own hack to set the transaction timeout,
> 
> You can use firecontrol to set it on-the-fly.  To set it on node ffc2 i.e. the
> node with phy ID 2, and controller 1 (i.e. libraw1394 "port" 1):
> # echo "w . 2 0xfffff0000018 4 3" | firecontrol 1
> 
> This sets the whole-seconds part to 3, which gives you 3.1 seconds timeout if
> the fractional part at 0xfffff000001c is still at its default value of 0.1
> seconds, i.e. 800 << 19 (subsecond part in units of (1/8000)s shifted by 19).
> 
> # { echo "r . 2 0xfffff0000018 4"; echo "r . 2 0xfffff000001c 4"; } |
> firecontrol 1
> 
> displays the current register value on node ffc2 at port 1.  Type "help" in
> firecontrol for more available firecontrol commands.
Agreed.

But why the timeout is  never set?
What is the default?

I think that timeout_jiffies is never initialized, thus, it is 0 due to
kzalloc.

Also, note that I see here that if I send a TCP stream from one system
to another then the system that recieves the packets (and sends TCP
acks), still overflows the queue (error 10, and confirmed by printks).

Best regards,
	Maxim Levitsky

