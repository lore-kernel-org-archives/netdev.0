From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: forcedeth: version 0.20 available
Date: Mon, 22 Dec 2003 19:25:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDD7D@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>, "Manfred Spraul" <manfred@colorfullife.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-Class: urn:content-classes:message
To: "Carl-Daniel Hailfinger" <c-d.hailfinger.kernel.2003@gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> version 0.20 of forcedeth (GPLed nvnet replacement for nForce 
> on-board nics) for Linux 2.4 and 2.6 is available at 
> http://www.hailfinger.org/carldani/linux/patch> es/forcedeth/

Carl-Daniel, I'm bored:

* Consider prefixing function names unique prefix so driver is
  not anonymous in backtraces.
* remove_nic: use free_netdev rather than kfree.
* remove_nic: should check if(dev) before dereferencing?
* remove_nic: check np->rx_ring before pci_free_consistent?
* probe_nic: call to get_nvpriv(dev) before checking if(!dev).
* Need minimal ethtool support: GSET/SSET/GDRVINFO/GLINK/
  NWAY_RST.  ethtool_ops support would be best, but compat w/
  2.4 is problematic.
* Use mii.c to get some ethtool support, mii_ioctl support,
  and maybe a replacement for update_linkspeed.
* Comment above set_multicast says change_mtu.
* NAPI support would be nice instead of the do_nic_poll timer.
* Consider using NETIF_MSG_XXX levels to test against a
  np->msg_enable for better control over message output.
* Replace MODULE_PARM with module_param only for 2.6. 

Cheers,
-scott
