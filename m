From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sockopt: Make SO_BINDTODEVICE readable
Date: Mon, 22 Oct 2012 23:37:11 +0200
Message-ID: <1350941831.8609.1355.camel@edumazet-glaptop>
References: <508123AC.5080208@parallels.com>  <50858ABD.2000206@hp.com>
	 <1350938702.8609.1299.camel@edumazet-glaptop>  <5085B8B0.6010500@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:39936 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337Ab2JVVhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 17:37:16 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1171579eek.19
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 14:37:14 -0700 (PDT)
In-Reply-To: <5085B8B0.6010500@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-22 at 17:20 -0400, Brian Haley wrote:

> It's not much different from what's there:
> 
> 	setsockopt("foo");
> 
> 	rename foo -> bar
> 
> 	index = getsockopt();
> 	if_indextoname(index) -> "bar"
> 
> I more raised the issue since you pass a 'char *' to setsockopt() but an 'int *'
> to getsockopt(), I don't think any other value is non-symmetrical like this.
> 
> -Brian

I meant another cpu can be changing dev->name[] content while the
strcpy() is done, and you get a mangled devname, like "for" or "bao"
instead of "foo" or "bar"

But yes, I obviously understood your point about "char *" and "int *"
