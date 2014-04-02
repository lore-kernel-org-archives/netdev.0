From: Madoka Komatsubara <m-komatsubara@ab.jp.nec.com>
Subject: RE: fail to add 64 VLANs or more when SR-IOV is enabled
Date: Wed, 2 Apr 2014 09:11:26 +0000
Message-ID: <9DE5760509B7974286F38D93BF31DD62C7DF93@BPXM13GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	Hiroshi Baba <h-baba@ax.jp.nec.com>
To: "donald.c.skidmore@intel.com" <donald.c.skidmore@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([210.143.35.52]:37711 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835AbaDBJMg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 05:12:36 -0400
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>-----Original Message-----
>From: Komatsubara Madoka(小松原 円) 
>Sent: Thursday, March 27, 2014 6:11 PM
>To: 'linux-kernel@vger.kernel.org'; 'e1000-devel@lists.sourceforge.net'; 'netdev@vger.kernel.org'
>Cc: Shimamoto Hiroshi(島本 裕志); Baba Hiroshi(馬場 裕司)
>Subject: fail to add 64 VLANs or more when SR-IOV is enabled
>
>Hi all,
>
>
>We're facing an issue that we cannot add 64 VLANs or more per VF.
>When using SR-IOV, pass through a VF to the KVM guest and a lot of VLANs, we could add 63 VLANs using vconfig but we >failed to add 64th VLAN.
>We'd like to use many VLANs on the guest with SR-IOV.
>We're using Intel's 82599EB chip with ixgbe and ixgbevf driver.
>
>Has anyone seen the same issue?
>Is there any idea to solve this?
>

Hi Donald,

Do you also notice this problem?
We're facing an issue that we can use only 64 VLANs per VF.
We're using Intel's 82599EB chip with ixgbe and ixgbevf driver.


Is it subject to the specification restrictions only 64 VLAN can use per VF?
We'd like to use about 2000 VLAN per VF.

Does it come from hardware?



Regards,
Madoka Komatsubara


>The below instruction is a reproducing method.
>Create hundred VLANs on the guest.
>
># for i in `seq 100 199`; do vconfig add eth2 $i; ifconfig 192.168.$i.1/24; done
>
># vconfig add eth2 100
>Added VLAN with VID == 100 to IF -:eth2:-
>
># vconfig add eth2 101
>Added VLAN with VID == 101 to IF -:eth2:-
>
># vconfig add eth2 102
>Added VLAN with VID == 102 to IF -:eth2:-
>
>...
>
># vconfig add eth2 162
>Added VLAN with VID == 162 to IF -:eth2:-
>
># vconfig add eth2 163
>ERROR: trying to add VLAN #163 to IF -:eth2:-  error: Permission denied
>SIOCSIFADDR: No such device
>eth2.163: unknown interface: No such device
>
># vconfig add eth2 164
>ERROR: trying to add VLAN #164 to IF -:eth2:-  error: Permission denied
>SIOCSIFADDR: No such device
>eth2.164: unknown interface: No such device
>
># vconfig add eth2 165
>ERROR: trying to add VLAN #165 to IF -:eth2:-  error: Permission denied
>SIOCSIFADDR: No such device
>eth2.165: unknown interface: No such device
>
>
>thanks,
>Madoka Komatsubara
