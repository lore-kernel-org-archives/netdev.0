From: "Shawn J. Goff" <shawn.goff@accelecon.com>
Subject: qmi-wwan bug
Date: Wed, 24 Oct 2012 14:50:04 -0400
Message-ID: <5088385C.1090304@accelecon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hub027-nj-6.exch027.serverdata.net ([206.225.167.250]:2229 "EHLO
	hub027-nj-6.exch027.serverdata.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934943Ab2JXS6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 14:58:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've backported qmi-wwan to 2.6.39 (it's here: 
https://bitbucket.org/accelecon/linux-at91/changesets), and it mostly 
works, but I've come across a problem. The modem will sometimes stop 
responding to any qmi data (but the AT commands on the TTY ports keep 
working). This only happens when there is significant traffic flowing 
through the device (downloading a large file) while at the same time, AT 
commands are sent to one of the TTY ports (I first noticed with my own 
modem query program, but I can reproduce it using microcom to send 
"ATI\r" in a loop). I see this problem with different devices from 
different manufacturers. I've only made it happen on my kernel - I tried 
on 3.6.2, but it seems to not happen there. I've also tried using a 
similar modem that uses a different driver (sierra-net) and that doesn't 
have the same problem.

When it is in failure, if I try to ping an address, the system sends out 
several an ARP requests but gets no response. To get the device to 
respond again, I have to administratively set the wwan interface down, 
then up, use libqmi to get the connection going again, then dhcp to get 
an address.

I also have some USB traces of the failure and recovery process. I'm not 
familiar with CDC or QMI, so it's not yet clear to me exactly what's 
happening, but it looks like the modem just stops sending anything on 
its QMI endpoint for no reason.

How might I dive further into the issue? So far, my next step is to look 
into CDC and QMI and try to decypher the USB traces. If anyone is 
interested, I can share a tcpdump or a USB trace.

-- 
Shawn J. Goff | Accelerated Concepts | Embedded Systems Engineer | 1-813-983-7501
