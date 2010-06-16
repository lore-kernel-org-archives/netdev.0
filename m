From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ipv6: netif_carrier_(on|off) with traces afterwards
Date: Wed, 16 Jun 2010 09:55:45 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FF43AB7B9@rrsmsx501.amr.corp.intel.com>
References: <OF3A036420.64516D4F-ONC1257744.00492A34-C1257744.004A240B@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: NetDev <netdev@vger.kernel.org>
To: Einar EL Lueck <ELELUECK@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6995 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755071Ab0FPPzw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 11:55:52 -0400
In-Reply-To: <OF3A036420.64516D4F-ONC1257744.00492A34-C1257744.004A240B@de.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Einar EL Lueck
>Sent: Wednesday, June 16, 2010 6:30 AM
>To: netdev@vger.kernel.org
>Subject: ipv6: netif_carrier_(on|off) with traces afterwards
>
>
>Hi,
>With IPv6 addresses configured and and a network card doing
>netif_carrier_off|on we see afterwards in 2.6.34 on S/390 some traces in
>fib.
>
>Example sequence of operations:
>ip -6 addr add fd00:10:30:49:4008:ffff:35:2/80 dev eth1
>ip link set eth1 up
>ip link set eth1 down
># the following lines have as effect netif_carrier_off and then on (among
>other stuff)
>echo 0 > /sys/bus/ccwgroup/drivers/qeth/devices/0.0.e300/online
>echo 1 > /sys/bus/ccwgroup/drivers/qeth/devices/0.0.e300/online
># end of plugging
>ip link set eth1  up
>ip link set eth1 down
>=> at this point we get the following trace:
>
>Badness
>at /home/autobuild/BUILD/linux-2.6.34-20100531/net/ipv6/ip6_fib.c:1160

<snip>

>
>Has anybody seen effects like this before on other platforms, or has
>anybody suggestions for the root cause?

I had similar issues. The following patches fixed it for me:

http://marc.info/?l=linux-netdev&m=127472600330413

http://marc.info/?l=linux-netdev&m=127472599530407

Thanks,
Emil

