From: Nathan Grennan <linux-netdev@cygnusx-1.org>
Subject: sky2 0000:02:00.0: error interrupt status=0x8
Date: Tue, 26 Feb 2008 18:30:47 -0800
Message-ID: <47C4CB57.2060004@cygnusx-1.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from okcforum.org ([69.17.49.173]:33453 "EHLO mail.okcforum.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752060AbYB0Cjf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 21:39:35 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.okcforum.org (Postfix) with ESMTP id A438152B11B
	for <netdev@vger.kernel.org>; Tue, 26 Feb 2008 18:30:47 -0800 (PST)
Received: from mail.okcforum.org ([127.0.0.1])
	by localhost (okcforum.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IIYx4Fbb12+v for <netdev@vger.kernel.org>;
	Tue, 26 Feb 2008 18:30:47 -0800 (PST)
Received: from ws.cygnusx-1.org (dsl093-181-075.sfo4.dsl.speakeasy.net [66.93.181.75])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.okcforum.org (Postfix) with ESMTP id 73F6D52B118
	for <netdev@vger.kernel.org>; Tue, 26 Feb 2008 18:30:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    I am using the sky2 driver in kernel-2.6.23.15-137.fc8.x86_64 with 
my Marvell 88E8056 to do iSCSI. I have many errors in dmesg like the 
ones below. If I count just the lines that match the first one, there 
are over 1500. If I include the suppressed lines it is over 100k. At 
first I got three of these doing something and then didn't see it for a 
while. I suspect the 100k came from a download of an 8gb file from the 
internet that was being written to the remote machine via iSCSI. The 
download took about an hour and fifteen minutes. I would ignore just 
three of these, but 100k of them suggests a real problem to me.

sky2 0000:02:00.0: error interrupt status=0x8
printk: 77 messages suppressed.


 I am using a MTU of 9000. Between the two computers is a D-Link 
*DGS-2208 *switch that supports jumbo frames. The remote card uses the 
forcedeth driver.

 This from the kernel package changelog seems like it might apply.

* Mon Jul 09 2007 Chuck Ebbert <cebbert@redhat.com>
- sky2: restore workarounds for lost interrupts


Local dmesg:
sky2 0000:02:00.0: v1.18 addr 0xfe8fc000 irq 17 Yukon-EC Ultra (0xb4) rev 2

Local lspci:
02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056 PCI-E 
Gigabit Ethernet Controller (rev 12)

Local iSCSI Initiator software:
iscsi-initiator-utils-6.2.0.865-0.2.fc8.x86_64

Remote dmesg:
forcedeth.c: Reverse Engineered nForce ethernet driver. Version 0.60.
forcedeth: using HIGHDMA
eth0: forcedeth.c: subsystem: 01462:7125 bound to 0000:00:0a.0

Remote lspci:
00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev a3)

Remote iSCSI Target software:
scsi-target-utils-0.0-4.20071227snap.fc8.x86_64
