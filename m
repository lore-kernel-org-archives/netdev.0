From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Question about the hash used in XOR mode
Date: Sun, 21 Sep 2003 16:37:37 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309211637.37136.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In bond_xmit_xor(), we have the following:

slave = bond->prev;
.
.
.
slave_no = (data->h_dest[5]^slave->dev->dev_addr[5]) % bond->slave_cnt;

Which should give us a number between 0 and slave_cnt-1 which is constant
per destination address, hence acts as a hash function. But, the fact is
slave->dev->dev_addr[5] is the same the whole time, and is actually the
same as bond->device->dev_addr[5].

Is there a special meaning for XORing with a constant ?
Wouldn't it be the same is we did just:
	slave_no = data->h_dest[5] % bond->slave_cnt;

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
