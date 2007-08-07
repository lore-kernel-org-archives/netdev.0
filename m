From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Linx
Date: Tue, 7 Aug 2007 15:39:18 -0400
Message-ID: <20070807153918.231ee1ed@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42742 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752964AbXHGTiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 15:38:50 -0400
Received: from oldman (pool-141-154-144-75.wma.east.verizon.net [141.154.144.75])
	(authenticated bits=0)
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l77JchH3018504
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 7 Aug 2007 12:38:46 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After seeing this article on Linx
 http://www.linuxdevices.com/news/NS8613439087.html
I decided to give it a quick code review (long airline flight).
Overall, it isn't awful, it just looks like every other piece of code
that hasn't been managed for mainline kernel inclusion.
Nice way of saying, this turd needs a man year or more of polishing.

Gratiutious Code Review of Linx

0. Bugs.
   A. Device names can change in kernel at anytime, use pointers
      or ifindex. In fact any name change will crash kernel in
      BUG_ON in notifier
   B. Device's changing MTU will crash kernel in BUG_ON
   C. Calling del_timer_sync under RTNL

1. Coding Style
   A. Typedef's
      Don't use typedef's like LINX_SPID, ...
   B. Non-standard naming conventions
      I. Don't use uint32_t for kernel use u32 or __u32
      II. No MixedCaseNames
   C. Use std. macros
      I. BUG_ON vs. LINX_ASSERT, etc
   D. Code in macro's that should really be inline's
      (e.g. linx_check_linx_huntname)
   E. Indentation
   F. Excessive scope, much of the code could be local to one file
   G. Too many spelling errors
   H. OS Abstraction layer is unacceptable
   I. Use initializers when possible (e.g device_notifier)
   J. Quit with all the assert's for in_irq() in timer's etc...

2. Bogus wrappers
   A. Kmalloc
   B. Spinlocks

3. Unacceptable ABI
   A. ioctl's for special functions
   B. Heavy reliance on config parameters in /proc
   C. Looks dependent on Ethernet address format
   D. Code for non-standard adaptive coalesce
      and his code has protocol playing with drivers timers directly.
   E. Non-assigned number for Ethernet protocol

4. FYI
   A. No __init or __exit
   B. Kernel API documentation
      Only document API calls that matter not every pissant little function.
      Avoid stating the obvious.
      Why not use docbook format?
   C. Locking way to fine grained (lots of small locks)
      Should use RCU and avoid rwlocks
      Use existing linux network device API locks (ie dev_base_lock, RTNL)
      if possible.

Those who don't understand TCP/IP are doomed to reimplement it, badly.
