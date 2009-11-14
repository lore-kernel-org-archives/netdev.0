From: Satish Chowdhury <satish.chowdhury@oneconvergence.com>
Subject: Sharing VF device among Xen VMs
Date: Sun, 15 Nov 2009 01:19:31 +0530
Message-ID: <be5d34890911141149v45ba176ax5705d681def3470e@mail.gmail.com>
References: <be5d34890911130925j7b7d70f3j1f205b9ad7624b76@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:51446 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbZKNTtp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 14:49:45 -0500
Received: by iwn8 with SMTP id 8so3413065iwn.33
        for <netdev@vger.kernel.org>; Sat, 14 Nov 2009 11:49:51 -0800 (PST)
In-Reply-To: <be5d34890911130925j7b7d70f3j1f205b9ad7624b76@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to verify a situation where VMs share a VF device of Intel
82576 dual port for data traffic.

Setup:
Case -1: On a Vt-d machine Xen(xen-1) is installed. On dom0 multiple
VFs are created for 82576ET dual port card. One of the VF is
pass-through to a VM.=A0 Now, the VM again has Xen (xen-2) installed.
So, the VMs of Xen-2 have to share the passthrough VF device for data
traffic.

Will I be able to send data from Xen-2 VMs to external world?

I had issues while creating VMs for Xen2. So, could not do the experime=
nt.

Case-2:=A0 On Xen-1 itself I loaded igbvf driver. Changed xen
configuration to make VF as default interface on dom0. Now VMs of
Xen-1 should share the VF device.

Ping from VF interface on VM=A0 and PF ip address works.
Ping between VMs goes through.
But, ping from domU to another machine on same network on switch doesn'=
t work.

The arp broadcast request goes out through VF interface. But the arp
reply doesn't reach VF interface, they get routed to PF interface. If
PF interface to the bridge on dom0 then ping from VMs to external
machine work.

In my experiment, the arp reply that reaches the NIC, has mac address
of interface on VM(domU). 82576 performs L2 filtering based on VF MAC
address. So, packet is not queued to VF interface.

Is it possible to add VMs mac address to L2 filtering pool of the NIC?

Regards,
-Satish
