From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] net: correct check in dev_addr_del()
Date: Thu, 15 Nov 2012 11:12:38 +0100
Message-ID: <20121115101238.GA2807@minipsycho.orion>
References: <1352897464-832-1-git-send-email-jiri@resnulli.us>
 <20121114.215254.973344009331632746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	shemminger@vyatta.com, john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48374 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423250Ab2KOKMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 05:12:42 -0500
Received: by mail-ee0-f46.google.com with SMTP id b15so852056eek.19
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2012 02:12:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121114.215254.973344009331632746.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 15, 2012 at 03:52:54AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 14 Nov 2012 13:51:04 +0100
>
>> Check (ha->addr == dev->dev_addr) is always true because dev_addr_init()
>> sets this. Correct the check to behave properly on addr removal.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>I'm pretty sure this is very intentional.
>
>It's trying to prevent deletion of the implicit dev->dev_addr
>entry.  But it will allow decementing the reference count to
>1, but no further.
>
>I'm not applying this.

Please look at dev_addr_init(), line 266:
dev->dev_addr = ha->addr;

and that is never changed.
Therefore check (ha->addr == dev->dev_addr) in dev_addr_del() is always
true and has no meaning.

dev_addr_del() should check if the address passed in "const unsigned
char *addr" function arg is the same as in ha->addr (dev->dev_addr) and
prevent to remove it in that case. And that is what this patch does.
