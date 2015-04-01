From: Manish Chopra <manish.chopra@qlogic.com>
Subject: Question regarding MAC address configuraton with VLAN devices
Date: Wed, 1 Apr 2015 19:15:54 +0000
Message-ID: <31AFFC7280259C4184970ABA9AFE8B93E0930C40@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:10453 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752799AbbDATQD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 15:16:03 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello Patrick,

I have a question regarding MAC address configuration of network devices specially
when VLANs are configured on that. Can you please help to address?

When user changes MAC address of a base network device [e.g., via ifconfig]
why existing VLAN device on top of that would add it's previous MAC address to
unicast list of base device instead of adapting the new MAC address
in it's own net device?

What we are trying to achieve here is that -

For a VF, if Hypervisor/Administrator has forced a MAC [e.g., via iproute2] then as a part of 
"learning process [of the new hypervisor forced mac] done by VF driver", it will simply call
"call_netdevice_notifiers(NETDEV_CHANGEADDR, dev)", which would notify the address change
to VLAN interfaces configured on top of VF device and they will adapt the hypervisor forced MAC too.
But that's not seems to be the behavior here, instead VLAN device on top of the VF device seems to be adding
It's previous MAC address to unicast list of base VF device. This configuration will not take effect
[since PF is blocking the VF's additional unicast MACs, if once a MAC has been forced to the VF], thus
effectively the VLAN interface will never receive traffic with it's configured MAC.


Regards,
Manish
