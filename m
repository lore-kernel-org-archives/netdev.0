From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: Sharing VF device among Xen VMs
Date: Mon, 16 Nov 2009 09:39:10 -0800
Message-ID: <43F901BD926A4E43B106BF17856F075589F8EC25@orsmsx508.amr.corp.intel.com>
References: <be5d34890911130925j7b7d70f3j1f205b9ad7624b76@mail.gmail.com>
 <be5d34890911141149v45ba176ax5705d681def3470e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Satish Chowdhury <satish.chowdhury@oneconvergence.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53729 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751458AbZKPRjG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 12:39:06 -0500
In-Reply-To: <be5d34890911141149v45ba176ax5705d681def3470e@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.or=
g]
>On Behalf Of Satish Chowdhury
>Sent: Saturday, November 14, 2009 11:50 AM
>To: netdev@vger.kernel.org
>Subject: Sharing VF device among Xen VMs
>
>Hi,
>
>I am trying to verify a situation where VMs share a VF device of Intel
>82576 dual port for data traffic.
>
>Setup:
>Case -1: On a Vt-d machine Xen(xen-1) is installed. On dom0 multiple
>VFs are created for 82576ET dual port card. One of the VF is
>pass-through to a VM.=A0 Now, the VM again has Xen (xen-2) installed.
>So, the VMs of Xen-2 have to share the passthrough VF device for data
>traffic.
>
>Will I be able to send data from Xen-2 VMs to external world?
>
>I had issues while creating VMs for Xen2. So, could not do the
>experiment.
>
>Case-2:=A0 On Xen-1 itself I loaded igbvf driver. Changed xen
>configuration to make VF as default interface on dom0. Now VMs of
>Xen-1 should share the VF device.
>
>Ping from VF interface on VM=A0 and PF ip address works.
>Ping between VMs goes through.
>But, ping from domU to another machine on same network on switch doesn=
't
>work.
>
>The arp broadcast request goes out through VF interface. But the arp
>reply doesn't reach VF interface, they get routed to PF interface. If
>PF interface to the bridge on dom0 then ping from VMs to external
>machine work.
>
>In my experiment, the arp reply that reaches the NIC, has mac address
>of interface on VM(domU). 82576 performs L2 filtering based on VF MAC
>address. So, packet is not queued to VF interface.
>
>Is it possible to add VMs mac address to L2 filtering pool of the NIC?
>
>Regards,
>-Satish
>--
[Rose, Gregory V]=20

No, there is no tool for this right now.  Extensions to the iproute2 pa=
ckage are under review internally and either a set of proposed patches =
or an RFC should be forthcoming soon.

You are correct that you need to be able to add the MAC addresses of VM=
s using the bridge interface to the L2 filter table of the NIC before t=
his setup will work correctly.

=46or now the 82576 in SR-IOV modes of operation only supports communic=
ation among the VFs.  You should not try to use the physical function a=
s a bridge interface until the tool I mentioned above becomes available=
=2E

- Greg
