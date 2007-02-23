From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [Kgdb-bugreport] [PATCH 2.6.20-rc7] 8139too KGDBoE fix
Date: Fri, 23 Feb 2007 22:09:16 +0300
Message-ID: <45DF3BDC.2070806@ru.mvista.com>
References: <200701312144.56497.sshtylyov@ru.mvista.com>	<45DDBD96.10000@ru.mvista.com>	<45DDC7C0.8050100@ru.mvista.com>	<200702231238.40474.amitkale@linsyssoft.com>	<45DF2E20.305@mvista.com> <20070223110451.44066f09@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Huth <mhuth@mvista.com>,
	"Amit S. Kale" <amitkale@linsyssoft.com>, netdev@vger.kernel.org,
	Mithlesh Thukral <mithlesh@linsyssoft.com>,
	Vitaly Wool <vwool@ru.mvista.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:42377 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933180AbXBWTJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 14:09:32 -0500
In-Reply-To: <20070223110451.44066f09@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Stephen Hemminger wrote:

>>>This thread came up on kgdb-bugreport mailing list. Could you please suggest 
>>>us what's the correct way of fixing this problem?

>>>1. When running a kgdb on RTL8139 ethernet interface: 8139too driver prints 
>>>too many "Out-of-sync dirty pointer" messages on console and gdb can't 
>>>connect to kgdb stub. These messages can be suppressed, though it still 
>>>results in connection failures frequently. 

>>We think this comes from calling the driver while the queue is stopped.  
>>Drivers should not do horrible things when hard start is called with the 
>>queue stopped, but unfortunately, at this time, at least some drivers 
>>do  explode or complain under that condition.

> The kernel is built on a set of assumptions about calling context. Your
> out of tree code is violating one of them. Why not check for stopped queue
> and do some action to try and clear it, that is what netconsole does.

    The queue can't be stopped when the netpoll traffic trapping is enabled 
(cause this effectively bypasses queue control), So, the stopped queue 
indoication doesn't work also -- *that* is the problem. It's not at all 
specific to KGBoE -- only to traffic trapping.

WBR, Sergei
