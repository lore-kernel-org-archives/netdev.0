From: Ulf Samuelsson <netdev@emagii.com>
Subject: netlink NETLINK_ROUTE  failure & Can the kernel really handle IPv6
 properly
Date: Wed, 01 Oct 2014 22:28:46 +0200
Message-ID: <542C63FE.9080807@emagii.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxf5.bahnhof.se ([213.80.101.29]:43483 "EHLO mxf5.bahnhof.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbaJAU46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 16:56:58 -0400
Received: from localhost (mxf5.local [127.0.0.1])
	by mxf5-reinject (Postfix) with ESMTP id 9C1E590A16D
	for <netdev@vger.kernel.org>; Wed,  1 Oct 2014 22:28:57 +0200 (CEST)
Received: from mxf5.bahnhof.se ([127.0.0.1])
	by localhost (mxf5.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6jUjzhtNMvob for <netdev@vger.kernel.org>;
	Wed,  1 Oct 2014 22:28:49 +0200 (CEST)
Received: from smtp-auth3.bahnhof.se (unknown [195.178.168.26])
	by mxf5.bahnhof.se (Postfix) with ESMTP id F2EE690A16A
	for <netdev@vger.kernel.org>; Wed,  1 Oct 2014 22:28:48 +0200 (CEST)
Received: from [10.175.196.210] (h-169-18.a454.priv.bahnhof.se [37.123.169.18])
	(Authenticated sender: mb782575)
	by smtp-auth3.bahnhof.se (Postfix) with ESMTPA id 95142285EF
	for <netdev@vger.kernel.org>; Wed,  1 Oct 2014 22:28:47 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Trying to write a kernel module handing NETLINK_ROUTE messages for a 
3.4.x kernel.

After building the module, it fails to load on my PowerPC P2020 target.
Reason is that the "netlink_kernel_create" fails.



---------------------------------------
struct *sock    nls;

...
static int __init my_init (...)
{
     ...
     nls = netlink_kernel_create( &init_net, NETLINK_ROUTE, 0, my_rcv, 
NULL, THIS_MODULE);
     if (!nls) {
             return -ENOMEM;
     }
...
}
----------------------------------------
netlick_kernel_create returns 0, so the kernel module fails.

Is there anything wrong wth the call to netlink_kernel_create ?

Goggling show that some code uses "__net_init".
Not sure what that means.

Other code uses a mutex, instead of NULL.
Does NETLINK_ROUTE require a mutex?

All ideas are welcome-

==============
BTW, the problem I am trying to solve is how to connect to an I/F with 
an IPv6 link-local address.

An existing kernel module waits for a NETDEV_UP event, and then tries to 
communicate
with the link-local address.

This will fail, because (according to a colleague) the I/F enters a 
"tentative" state,
where it is trying to decide if it is unique or not.
It will remain in that state for 1-2 seconds, and only afterwards is the 
link-local address
available for normal use.

The guys writing the module, claim that the kernel is using NETDEV_UP.
There is very little code in the kernel using NETLINK_ROUTE, even in 
latest stable.
It is using NETDEV_UP.

If my colleague is right, the kernel really cannot handle IPv6 
link-local addresses properly.

-- 
Best Regards
Ulf Samuelsson
