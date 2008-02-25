From: Li Yewang <lyw@cn.fujitsu.com>
Subject: [NET] Can not send icmp netunreach packet
Date: Mon, 25 Feb 2008 16:28:04 +0800
Message-ID: <47C27C14.4010208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: swhiteho@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49743 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753798AbYBYI3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 03:29:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steven
 
    There is a bug about icmp netunreach.
    If the kernel does not find a route for a packet, it must send a 
icmp netunreach packet
    to the source host, and  discard  the packet.
    But the latest kernel  does not send a icmp netunreach packet 
because of the  fib_lookup
    return value  of -ESRCH when a route  is not found.

    I found a your patch about why 
changes the "not found" error return for the
    lookup function to -ESRCH. But I think this is not correct.
  
    Your patch is as following:      
   
http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=83886b6b636173b206f475929e58fac75c6f2446

     
