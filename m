From: Madoka Komatsubara <m-komatsubara@ab.jp.nec.com>
Subject: fail to add 64 VLANs or more when SR-IOV is enabled
Date: Thu, 27 Mar 2014 09:10:32 +0000
Message-ID: <9DE5760509B7974286F38D93BF31DD62C7CAA1@BPXM13GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	Hiroshi Baba <h-baba@ax.jp.nec.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Language: ja-JP
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi all,


We're facing an issue that we cannot add 64 VLANs or more per VF.
When using SR-IOV, pass through a VF to the KVM guest and a lot of VLANs,
we could add 63 VLANs using vconfig but we failed to add 64th VLAN.
We'd like to use many VLANs on the guest with SR-IOV.
We're using Intel's 82599EB chip with ixgbe and ixgbevf driver.

Has anyone seen the same issue?
Is there any idea to solve this?

The below instruction is a reproducing method.
Create hundred VLANs on the guest.

# for i in `seq 100 199`; do vconfig add eth2 $i; ifconfig 192.168.$i.1/24; done

# vconfig add eth2 100
Added VLAN with VID == 100 to IF -:eth2:-

# vconfig add eth2 101
Added VLAN with VID == 101 to IF -:eth2:-

# vconfig add eth2 102
Added VLAN with VID == 102 to IF -:eth2:-

...

# vconfig add eth2 162
Added VLAN with VID == 162 to IF -:eth2:-

# vconfig add eth2 163
ERROR: trying to add VLAN #163 to IF -:eth2:-  error: Permission denied
SIOCSIFADDR: No such device
eth2.163: unknown interface: No such device

# vconfig add eth2 164
ERROR: trying to add VLAN #164 to IF -:eth2:-  error: Permission denied
SIOCSIFADDR: No such device
eth2.164: unknown interface: No such device

# vconfig add eth2 165
ERROR: trying to add VLAN #165 to IF -:eth2:-  error: Permission denied
SIOCSIFADDR: No such device
eth2.165: unknown interface: No such device


thanks,
Madoka Komatsubara

------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
