From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Fri, 28 Mar 2008 17:34:14 -0700 (PDT)
Message-ID: <20080328.173414.22278840.davem@davemloft.net>
References: <20080328000013.GA8193@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37184
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753995AbYC2AeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 20:34:14 -0400
In-Reply-To: <20080328000013.GA8193@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Thu, 27 Mar 2008 20:00:13 -0400

>  stack backtrace:
>  Pid: 2308, comm: NetworkManager Not tainted 2.6.25-0.161.rc7.fc9.i686 #1
>   [print_circular_bug_tail+91/102] print_circular_bug_tail+0x5b/0x66
>   [print_circular_bug_entry+57/67] ? print_circular_bug_entry+0x39/0x43
>   [__lock_acquire+2488/3089] __lock_acquire+0x9b8/0xc11
>   [_spin_unlock_irq+34/47] ? _spin_unlock_irq+0x22/0x2f
>   [lock_acquire+106/144] lock_acquire+0x6a/0x90
>   [flush_workqueue+0/133] ? flush_workqueue+0x0/0x85
>   [flush_workqueue+68/133] flush_workqueue+0x44/0x85
>   [flush_workqueue+0/133] ? flush_workqueue+0x0/0x85
>   [flush_scheduled_work+13/15] flush_scheduled_work+0xd/0xf
>   [<d096d80a>] tulip_down+0x20/0x1a3 [tulip]
>   [trace_hardirqs_on+233/266] ? trace_hardirqs_on+0xe9/0x10a
>   [dev_deactivate+177/222] ? dev_deactivate+0xb1/0xde

Yes, see for example:

http://www.mail-archive.com/netdev@vger.kernel.org/msg31718.html

You can't flush a workqueue in the device close handler
exactly because of this locking conflict.

Nobody has come up with a suitable way to fix this yet.
