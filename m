From: Erwan Velu <erwanaliasr1@gmail.com>
Subject: Remarks and comments about ipconfig behavior
Date: Thu, 13 Sep 2012 22:21:15 +0200
Message-ID: <5052403B.4040408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:32791 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756092Ab2IMUVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:21:24 -0400
Received: by eaac11 with SMTP id c11so1435764eaa.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 13:21:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Fellows !

I've been figuring a strange behavior today and I'd like to share with 
you both experience and remarks.

On my system that runs a 3.2.29 but that's also applicable with 
linux-next and all other releases.

As shown here : 
http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=blob;f=net/ipv4/ipconfig.c;h=67e8a6b086ea7a0d2c4cc986ed6ed0e6b4414c6a;hb=HEAD#l262 
, if you specify an ip= option on the cmdline, the kernel is expecting 
the carrier to be present unless it will make a loop up to 2mn as per 
CONF_CARRIER_TIMEOUT value.

That lever for me two points :
- why is this timeout setup for so long ? Even with a spantree 
configuration, not having a carrier for 2mn is *waow* ... Does a 30sec 
could not be enough ? What is the need of waiting so long time ?

- Until we get the carrier, the kernel just stops and the boot process 
is totally locked but there isn't any message shown to the user. The 
system really look like frozen/dead for 2 minutes.

I spent a complete day trying to understand why my box was unable to 
boot while the network cable was removed.
I just discover this behavior by comparing log files to understand that 
was the reason.


So my suggestion would be the following and I can offer patches if you 
agree on thoses points :


- reducing the timeout to something smaller like 30sec
- display a message every second to inform the user we are waiting the 
carrier to satisfy the ipconfig option

What are you thoughts on that ?

Thanks you,
Erwan Velu
