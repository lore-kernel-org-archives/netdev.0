From: Marcel Holtmann <marcel@holtmann.org>
Subject: Problem with platform specific RFKILL switches
Date: Fri, 09 Jan 2009 20:15:49 +0100
Message-ID: <1231528549.20618.34.camel@californication>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:58197 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992AbZAITPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 14:15:52 -0500
Received: from [192.168.1.142] (S0106001cf062885c.vc.shawcable.net [24.82.150.230])
	by mail.holtmann.org (Postfix) with ESMTP id 87BA98B547
	for <netdev@vger.kernel.org>; Fri,  9 Jan 2009 20:15:53 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

so I am working with RFKILL subsystem right now. One major problem that
I have is that in the cases of platform RFKILL switches, I have no idea
which device it actually belongs to. Lets take my X61 as an example:

# udevadm info --query=all --path=/class/rfkill/rfkill0
P: /devices/platform/thinkpad_acpi/rfkill/rfkill0
E: UDEV_LOG=3
E: DEVPATH=/devices/platform/thinkpad_acpi/rfkill/rfkill0
E: RFKILL_NAME=tpacpi_bluetooth_sw
E: RFKILL_TYPE=bluetooth
E: RFKILL_STATE=1

# udevadm info --query=all --path=/class/rfkill/rfkill1
P: /devices/pci0000:00/0000:00:1c.1/0000:03:00.0/rfkill/rfkill1
E: UDEV_LOG=3
E: DEVPATH=/devices/pci0000:00/0000:00:1c.1/0000:03:00.0/rfkill/rfkill1
E: RFKILL_NAME=4965AGN
E: RFKILL_TYPE=wlan
E: RFKILL_STATE=1

As you can see for the 4965 WiFi, we clearly have a proper parent and
know which device is affected by the RFKILL switch. For the Bluetooth
one we have the problem that it just points to a platform device and not
the Bluetooth device.

Do we have any plans on how to handle this? I would like to identify the
affected device. It is kinda tricky with hotplug devices like Bluetooth
were it just disconnects from the bus when using the RFKILL switch, but
at least when enabled we would see which device is attached to it.

So any ideas or is this just wishful thinking on my part?

Regards

Marcel


