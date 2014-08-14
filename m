From: Yoann Juet <veilletechno-irts@univ-nantes.fr>
Subject: ixgbe: SR-IOV, macvlan filter on VFs
Date: Thu, 14 Aug 2014 14:04:25 +0200
Message-ID: <53ECA5C9.2020904@univ-nantes.fr>
Reply-To: Yoann Juet <veilletechno-irts@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: Yoann Juet <yoann.juet@univ-nantes.fr>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtptls1-cha.cpub.univ-nantes.fr ([193.52.103.113]:50219 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753901AbaHNMKV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 08:10:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

We are trying to make VRRP with VMAC address work on VMs using SR-IOV. 
The well known Keepalived VRRP framework implements such a feature with 
a macvlan device per physical interface. In our setup, this means we get 
a new macvlan device per VF. To make it partially work, we first have to 
disable the ixgbe anti-spoofing feature on the PFs that are involved:

ip link set dev <ethX> vf <x> spoofchk off

Now, VIPs' Virtual Mac Address are known from clients (arp answers are 
transmitted). But this is not enough ; VIPs are still not reachable from 
clients as they are attached to a macvlan device. Each time a VMAC is 
set on a macvlan device, we get the following messages:

[674943.437989] ixgbe 0000:04:00.0 eth2: VF 0 requested MACVLAN filter 
but is administratively denied
[674943.458875] ixgbe 0000:04:00.0 eth2: VF 1 requested MACVLAN filter 
but is administratively denied

Looks like macvlan on VF only works for outbound traffic from VMs. 
Inbound traffic is filtered. Is there a solution to disable macvlan 
filtering on a VF basis ?

Thanks,
Best Regards,
