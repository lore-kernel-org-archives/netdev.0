From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Via Velocity minimum MTU size
Date: Sun, 21 May 2006 21:56:49 -0500
Message-ID: <1148266609.2329.16.camel@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf18aec.mail.bellsouth.net ([205.152.59.66]:53475 "EHLO
	imf18aec.mail.bellsouth.net") by vger.kernel.org with ESMTP
	id S964990AbWEVC4w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 May 2006 22:56:52 -0400
Received: from ibm61aec.bellsouth.net ([74.227.55.112])
          by imf18aec.mail.bellsouth.net with ESMTP
          id <20060522025651.ULCV28780.imf18aec.mail.bellsouth.net@ibm61aec.bellsouth.net>
          for <netdev@vger.kernel.org>; Sun, 21 May 2006 22:56:51 -0400
Received: from [192.168.1.3] (really [74.227.55.112])
          by ibm61aec.bellsouth.net with ESMTP
          id <20060522025650.ECTL4087.ibm61aec.bellsouth.net@[192.168.1.3]>
          for <netdev@vger.kernel.org>; Sun, 21 May 2006 22:56:50 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, 

I was advised by someone on the fedora-devel-list to post my question
here.

I'm trying to set the MTU size on my Via Velocity 6122 Gbit adapter from
the default of 1500 down to 1492, but I keep getting this error:

[root@osprey ~]# ifconfig eth0 mtu 1492
SIOCSIFMTU: Invalid argument

Turns out that via-velocity.h defines the minimum MTU at 1500 bytes.

#define VELOCITY_MIN_MTU    (1514-14)
#define VELOCITY_MAX_MTU    (9000)


And via-velocity.c enforces the limit.

    if ((new_mtu < VELOCITY_MIN_MTU) || new_mtu > (VELOCITY_MAX_MTU)) {
         VELOCITY_PRT(MSG_LEVEL_ERR, KERN_NOTICE "%s: Invalid MTU.\n",
                                vptr->dev->name);
         return -EINVAL;
    }

This is an Abit AV8 motherboard with an Athlon64 3000+ cpu running
Fedora Core 5, kernel 2.6.16-1.2111_FC5 x86_64.

Can someone please explain why the driver might constrain the NIC to a
minimum MTU size of 1500?

Thanks,
Jay


