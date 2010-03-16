From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NET: netpoll, fix potential NULL ptr dereference
Date: Tue, 16 Mar 2010 14:29:37 -0700 (PDT)
Message-ID: <20100316.142937.144445591.davem@davemloft.net>
References: <1268759527.25503.2980.camel@calx>
	<4B9FBE49.6010709@gmail.com>
	<1268762160.25503.2988.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jirislaby@gmail.com, jslaby@suse.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, danborkmann@googlemail.com
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48417
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760044Ab0CPV3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 17:29:16 -0400
In-Reply-To: <1268762160.25503.2988.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Mackall <mpm@selenic.com>
Date: Tue, 16 Mar 2010 12:56:00 -0500

> On Tue, 2010-03-16 at 18:22 +0100, Jiri Slaby wrote:
>> On 03/16/2010 06:12 PM, Matt Mackall wrote:
>> > I don't get it. The source of the branch tests for !ndev->npinfo and the
>> > original destination of the branch also tests for !ndev->npinfo. I don't
>> > see how it gets dereferenced.
>> 
>> Let's look at more of the context:
>>          if (!ndev->npinfo) {
>>                  npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
>>                  if (!npinfo) {         // npinfo is NULL
>>                          err = -ENOMEM;
>>                          goto release;
>>                  }
>> ...
>> release:                           // npinfo is still NULL
>>          if (!ndev->npinfo) {       // condition is the same (holds)
>>               // dereference below: vvvvvvvvvvvvvvv
>>                  spin_lock_irqsave(&npinfo->rx_lock, flags);
>>                  list_for_each_entry_safe(npe, tmp, &npinfo->rx_np, rx) {
>>                          npe->dev = NULL;
>>                  }
>>                  spin_unlock_irqrestore(&npinfo->rx_lock, flags);
>> 
>>                  kfree(npinfo);
>>          }
> 
> Ok, you're correct, I read the second test backwards.
> 
> Acked-by: Matt Mackall <mpm@selenic.com>

Applied, thanks everyone.
