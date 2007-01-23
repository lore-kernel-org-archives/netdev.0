From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [BUG] e100: eth0 appers many times in /proc/interrupts after
 resume
Date: Mon, 22 Jan 2007 16:15:29 -0800
Message-ID: <45B553A1.5010303@intel.com>
References: <1167599458.2662.8.camel@nigel.suspend2.net> <1167605481.12328.0.camel@localhost> <1167607994.2662.39.camel@nigel.suspend2.net> <1167644970.7142.6.camel@localhost> <1168317278.6948.9.camel@nigel.suspend2.net> <1168448689.7430.1.camel@localhost> <1168463852.3205.1.camel@nigel.suspend2.net> <1169407062.1932.4.camel@localhost> <20070121212209.GB8958@slug> <45B3DEF7.8020505@intel.com> <20070121220457.GC8958@slug>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrei Popa <andrei.popa@i-neo.ro>, linux-kernel@vger.kernel.org,
	nigel@suspend2.net, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35415 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932509AbXAWAP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 19:15:57 -0500
To: Frederik Deweerdt <deweerdt@free.fr>
In-Reply-To: <20070121220457.GC8958@slug>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frederik Deweerdt wrote:
> On Sun, Jan 21, 2007 at 01:45:27PM -0800, Auke Kok wrote:
>> Frederik Deweerdt wrote:
>>> On Sun, Jan 21, 2007 at 09:17:41PM +0200, Andrei Popa wrote:
>>>> It's the 10th resume and in /proc/interrupts eth0 appers 10 times.
>>> The e100_resume() function should be calling netif_device_detach and
>>> free_irq. Could you try the following (compile tested) patch?
>> I just fixed suspend/shutdown for e100 in 2.6.19, not sure why the problem still shows up. Since it's a driver/net issue, you 
>> should CC netdev on it tho, otherwise it might go unnoticed.
> Thanks for adding the CC
>> I'll open up the can-o-worms on this issue and see what's up with it.
>>
>> I'm not so sure that this patch is OK, and I wonder why it stopped working, because I spent quite some time fixing it only a 
>> few months ago. Did swsup change again? sigh...
> 
> I may well be wrong (It appears that most of the time I am :)), but the
> unbalanced netif_device_attach (in resume) looks suspicious.  resume()
> also calls request_irq, so calling free_irq on suspend seemed logical.

I just tested the patch and looked it over again. The patch works good and 
indeed fixes the problem, and netconsole works great. It even shows much of the 
suspend/resume over the wire, something which I can't remember seeing before 
with netconsole. reboot -f also works OK.

I'll push the patch upstream, thanks!

Auke
