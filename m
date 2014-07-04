From: David Laight <David.Laight@ACULAB.COM>
Subject: e1000e (82579LM) management mode under KVM/QEMU
Date: Fri, 4 Jul 2014 09:37:26 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726C745@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53595 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756462AbaGDJij convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2014 05:38:39 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02358-01 for <netdev@vger.kernel.org>;
 Fri,  4 Jul 2014 10:38:30 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing some issues with an e1000e (82579LM) interface if
the 'management mode' stuff is enabled to allow VNC+ console access.
This is an Ivy bridge cpu, so will be a Panther point (PCH7) chipset.

The 82579LM interface and a second 82574L one are 'passed through'
to a KVM/qemu VM and then bonded together.

The link is only coming up at 10M HDX (sometimes FDX) even after
replugging the cable.
(ping -s 60000 confirms that the reported speed is correct.)

Forcing n-way negotiation with ethtool results in the correct
100M/1G speed.

The failing system is running an ubuntu built 3.11 kernel.
I don't see the same problem on a non-VM with 3.14(ish) kernel
on the same motherboard.
Running a more recent kernel on the VM is a bit tricky.

I can't see any obvious changes since 3.11, but the driver code
has a lot of conditions based on the PCH (etc) type.
I'm not sure whether the VM kernel is using the correct functions.
I can't see any trace that indicates which host controller the
e1000e driver thinks the device is connected to.

Any hints on how to determine what is actually going on?

	David
