From: Ariel Elior <ariele@broadcom.com>
Subject: RE: bnx2x + SR-IOV, no internal L2 switching
Date: Wed, 12 Feb 2014 14:38:41 +0000
Message-ID: <6AE768456CEC4B4A9B2248CB6B87EB3E1BFF7EEE@SJEXCHMB05.corp.ad.broadcom.com>
References: <52FB7843.6050601@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "yoann.juet@univ-nantes.fr" <yoann.juet@univ-nantes.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:15993 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbaBLOim convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 09:38:42 -0500
In-Reply-To: <52FB7843.6050601@univ-nantes.fr>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Yoann Juet
> Sent: Wednesday, February 12, 2014 3:34 PM
> To: netdev@vger.kernel.org
> Subject: bnx2x + SR-IOV, no internal L2 switching

Hi Yoan,
57810 device does support l2 switching.
I find your terminology a little bit confusing and I have some further questions besides:

[Q1]: Are you attaching physical functions to VMs? I.e. are you passing through PFs to the VMs, or only virtual functions?

[Q2]: Are you using VFs only on VMs, or directly from the Hypervisor too?

[Q3]: You wrote "for instance the physical ethX has an IP address". That in itself is no problem and no surprise. You gave this as an example to traffic arriving where is shouldn't. Please elaborate.

[Q4]: Do you have vlan filters configured anywhere in your topology? Are they configured from Host or from Guest?
(in this respect host tagging would be 'ip link set eth0 vf 5 vlan 100' on the hypervisor while guest tagging would be 'ip link add link eth4 type vlan id 100' or 'vconfig add eth4 100' where eth0 is a PF and eth4 is a VF).

[Q5]: In the case you mentioned where you saw in a VM traffic which was destined to another VM: Did both VMs contain VFs? Were the VFs created from the same Physical Function? If not, what were the BDFs pf the respective PFs? Which mac addresses did you give the VFs?

[Q6]: Please isolate a specific case where switching is not behaving as expected and describe it in more detail:
Please describe the topology (which PFs are involved and which VFs. Who is assigned to which VMs)
Where are you sending data from (a VF, a PF, some peer on the network) and where is it arriving (perhaps arriving in multiple places)
Please detail the behavior you expect and the behavior you observe.
Please supply:
Mac addresses, ip addresses and masks, configured vlans (if any), promiscuous setting, etc.
ip -d -d link show on hypervisor and each of the VMs involved
ethtool -d from Hypervisor PFs 
dmesg from hypervisor

Please note we recently submitted some fixes to our tx-switching behavior:
In e8379c79 "bnx2x: fix VLAN configuration for VFs" we fixed an issue where traffic with the wrong vlan could still end up in a VM configured to a different vlan (hence my questions on vlans).
In c14db202 "bnx2x: Correct default Tx switching behavior" we fixed a connectivity issue with pf to vf connectivity.
Depending on your answers to the above, perhaps these might be relevant to your case.

Thanks,
Ariel
