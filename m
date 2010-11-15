From: Jeff Garzik <jeff@garzik.org>
Subject: the future of ethtool
Date: Mon, 15 Nov 2010 14:41:30 -0500
Message-ID: <4CE18CEA.5080502@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:52705 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757936Ab0KOTle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 14:41:34 -0500
Received: by vws13 with SMTP id 13so1858631vws.19
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 11:41:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for accepting ethtool maintainership.

There are two key unresolved issues with ethtool that are worth noting 
to the next maintainer.  Both of these come from years of user and 
customer complaints.

1) ethtool command line interface.

For 1,001 minor reasons of user taste and expectation, people tend to 
complain about the command line interface.  Due to script usage it is 
set in stone, and has been since before my tenure.  But users 
continually request something more flexible, often, in particular, 
wanting to set multiple settings in one execution, or wanting to apply 
the same setting to multiple interface in one execution.

Obviously one can script this, but, it is probably the #1 user request.

My thought was to create "nictool", a new tool with more flexible 
command line interface, using the same old ethtool ioctls currently in 
use today.  ('nictool' also solves a minor naming complaint from 
wireless and other people, who use ethtool on non-ethernet network 
interfaces)


2) multiple settings and the ethtool kernel interface

Another common complaint is related to multiple settings, and associated 
hardware NIC resets.

Many ethtool driver implementations look like this:

	ethtool_op_do_something()
		stop RX/TX
		apply settings
		perform full NIC reset, consuming much time
		start RX/TX

The problem arises when the user wishes to change multiple hardware 
attributes at the same time.  A user wishing to change 4 attributes 
could wind up with 4 ethtool(1) invocations, with 4 accompanying 
hardware NIC resets.  Time consuming, inefficient, and unnecessary.


Obviously the world has not ended without these changes, but these items 
do cause continued complaints from users, and we're here to be 
responsive to users presumably ;-)

	Jeff



