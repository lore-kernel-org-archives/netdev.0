From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: ipconfig: allow IP-Config over DSA devices
Date: Fri, 30 May 2014 11:08:45 -0700
Message-ID: <1401473326-21828-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org, jiri@resnulli.us,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:40312 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbaE3SJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 14:09:12 -0400
Received: by mail-ig0-f182.google.com with SMTP id uy17so1146225igb.9
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 11:09:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Lennert, Jiri,

This small patch allows us to use the kernel IP auto-configuration on DSA
enabled devices.

I initially started implementing the netdev_upper_dev_link() calls for the
DSA slave devices, but ended up realizing that although this might be useful,
the other drivers or protocols implementing these master/slave relantionship
are the bonding driver and the VLAN code.

None of these interfaces (bonding or VLAN) can be created by the kernel
without modifications, which means that user-space is there, and so we could
pivot_root over a NFS mounted share for instance, hence making the master/slave
net_device relationship not so useful for IP-Config.

This is not the case with DSA devices which are solely created by the kernel
based on platform configuration.

Let me know your thoughts. If you feel like something like:
netdev_is_upper_dev() or something like that is better.

Thanks!

Florian Fainelli (1):
  net: ipconfig: handle DSA enabled network devices

 net/ipv4/ipconfig.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

-- 
1.9.1
