From: Shirley Ma <mashirle@us.ibm.com>
Subject: ixgbe: macvlan on PF/VF when SRIOV is enabled
Date: Fri, 21 May 2010 13:30:46 -0700
Message-ID: <1274473846.8701.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kvm@vger.kernel.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Jeff,

macvlan doesn't work on PF when SRIOV is enabled. Creating macvlan has
been successful, but ping (icmp request) goes to VF interface not
PF/macvlan even arp entry is correct. I patched ixgbe driver, and
macvlan/PF has worked with the patch. But I am not sure whether it is
right since I don't have the HW spec. What I did for ixgbe driver was: 

1. PF's rar index is 0, VMDQ index is adatper->num_vfs;
2. VF's rar is based on rar_used_count and mc_addr_in_rar_count, VMDQ
index is ;
3. PF's secondary addresses is PF's rar index + i, VMDQ index is
adapter->num_vfs.


Before I submit the patch, I want to understand the right index
assignment for both rar index and VMDQ index, when SRIOV enabled:
1. VMDQ index for PF is adapter->num_vfs, or 0? rar index is 0?
2. PF's secondary address rar index is based on
rar_used_count/mc_addr_in_rar_count?
2. VF's VPDQ index is based on vf number?
3. VF's rar index is vf + 1, or should be based on rar_used_count?

I am also working on macvlan on VF. The question here is whether macvlan
on VF should work or not? Looks like ixgbevf secondary addresses are not
in receiver address filter, so macvlan on VF doesn't work.

Thanks
Shirley

