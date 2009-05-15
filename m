From: Deepjyoti Kakati <dkakati73@gmail.com>
Subject: removing a bonding_master (ver 3.3.0 driver) results in leftover
	kernel process?
Date: Fri, 15 May 2009 07:08:04 +0530
Message-ID: <9a2da8520905141838x3081f96l190e230823d79098@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:11736 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532AbZEOBiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 21:38:03 -0400
Received: by qw-out-2122.google.com with SMTP id 5so1314011qwd.37
        for <netdev@vger.kernel.org>; Thu, 14 May 2009 18:38:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

using bonding driver ver 3.3.0 (on fedora 10)

I am using the sysfs  to add a couple of interfaces as bonding_masters
and repeatedly removing and adding  during test cycles as in:

echo +bond_data > /sys/class/net/bonding_masters
..add slave eth ports..
...do work...
......
echo -bond_data > /sys/class/net/bonding_masters

every time I add it, seems to start a kernel process named after that
bond interface
but when removing, that proc is not killed.

it builds up after a period of testing and even kill -9/kill -15 isnt
killing them

Am I doing something wrong ? Can I prevent the buildup of these unwanted
processes that are presumably consuming resources ?



root      4958     2  0 May13 ?        S<     0:00 [bond_appmgmt]
root      4972     2  0 May13 ?        S<     0:00 [bond_data]
root      5603     2  0 May13 ?        S<     0:00 [bond_appmgmt]
root      5617     2  0 May13 ?        S<     0:00 [bond_data]
root      6370     2  0 May13 ?        S<     0:00 [bond_appmgmt]
root      6384     2  0 May13 ?        S<     0:00 [bond_data]
root      7098     2  0 May13 ?        S<     0:00 [bond_appmgmt]
root      7112     2  0 May13 ?        S<     0:00 [bond_data]
root      8136     2  0 May13 ?        S<     0:00 [bond_appmgmt]
root      8150     2  0 May13 ?        S<     0:00 [bond_data]
root      8722     2  0 May13 ?        S<     0:00 [bond_appmgmt]
root      8739     2  0 May13 ?        S<     0:00 [bond_data]


thanks
