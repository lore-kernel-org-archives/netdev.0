From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Problems using bonding with vlan
Date: Mon, 15 Sep 2003 16:42:05 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309151632.59915.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: amir.noam@intel.com, shmulik.hen@intel.com, tsippy.mendelson@intel.com,
   naom.marom@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Consider the following scenario:
# insmod <some-base-driver>
# insmod 8021q
# insmod bonding mode=X miimon=Y
# vconfig add bond0 10
# ifenslave bond0 eth0 eth1 ...
# ifconfig bond0.10 a.b.c.d

Now try to run ping - no traffic. Arp tables on all clients show that 
the server has hardware address 00:00:00:00:00:00 !

The only way for it to work is:
# ifenslave bond0 eth0 eth1 ...
# vconfig add bond0 10
# ifconfig bond0.10 a.b.c.d

But that's probably not the way things happen during boot via the 
network scripts.

I think we should add to the 8021q module the ability to listen to 
netdev events and to set it's hardware address whenever the 
underlying device changes it own, instead of just during the VLAN 
interface creation.

Comments ?

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
