From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [E1000-devel] [PATCH v2 3/3] ixgbe: Add new ndo to allow VF
 multicast promiscuous mode
Date: Tue, 24 Feb 2015 20:29:50 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250241E02@FMSMSX105.amr.corp.intel.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38867@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	=?iso-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38867@BPXM14GP.gisp.nec.co.jp>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Hiroshi Shimamoto [mailto:h-shimamoto@ct.jp.nec.com] 
>Sent: Thursday, February 19, 2015 5:01 PM
> Subject: [E1000-devel] [PATCH v2 3/3] ixgbe: Add new ndo to allow VF multicast promiscuous mode
>
>From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>
>Implements the new netdev op to allow VF multicast promiscuous mode.
>
>The administrator can allow to VF multicast promiscuous mode for only
>trusted VM. After allowing multicast promiscuous mode from the host,
>we can use over 30 IPv6 addresses on VM.
> # ./ip link set dev eth0 vf 1 mc_promisc on
>
>When disallowing multicast promiscuous mode, we can only use 30 IPv6 addresses.
> # ./ip link set dev eth0 vf 1 mc_promisc off
>
>Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
>CC: Choi, Sy Jong <sy.jong.choi@intel.com>

<snip>

+int ixgbe_ndo_set_vf_mc_promisc(struct net_device *netdev, int vf, bool setting)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 vmolr;

vmolr is unused variable in this function.

+
+	if (vf >= adapter->num_vfs)
+		return -EINVAL;
+
+	/* nothing to do */
+	if (adapter->vfinfo[vf].mc_promisc_allowed == setting)
+		return 0;
+
+	adapter->vfinfo[vf].mc_promisc_allowed = setting;
+
+	/* if VF requests multicast promiscuous */
+	if (adapter->vfinfo[vf].mc_promisc) {
+		if (setting)
+			ixgbe_enable_vf_mc_promisc(adapter, vf);
+		else
+			ixgbe_disable_vf_mc_promisc(adapter, vf);
+	}
+
+	return 0;
+}

Thanks,
Emil
