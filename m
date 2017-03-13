From: Jarod Wilson <jarod@redhat.com>
Subject: bond procfs hw addr prints
Date: Mon, 13 Mar 2017 19:45:50 -0400
Message-ID: <597da6f1-c0fc-ae23-94d1-d0fb3abb3176@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47612 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751243AbdCMXpv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 19:45:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got a bug report for someone using a Intel OPA devices in a bond, 
and it appears these devices have a hardware address length of 20, 
opposed to the typical 6 on ethernet. When they dump 
/proc/net/bonding/bondX, it only prints the first 6 of the address, per 
%pM and mac_address_string(), while sysfs for the interface does print 
the right thing, since it uses sysfs_print_mac(), which takes a length 
argument.

So the question is... What's the best route to take here? Expand %pM to 
support variable length hardware addresses? Use sysfs_* in procfs? 
Reinvent the wheel? Nothing I've tinkered with just yet feels very 
clean, on top of not actually working yet. :)

-- 
Jarod Wilson
jarod@redhat.com
