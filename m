From: "Mendelson, Tsippy" <tsippy.mendelson@intel.com>
Subject: RE: Problems using bonding with vlan
Date: Mon, 15 Sep 2003 17:18:37 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <2C83850C013A2540861D03054B478C0602012044@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: "Noam, Amir" <amir.noam@intel.com>, <naom.marom@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Hen, Shmulik" <shmulik.hen@intel.com>,
   <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Another option would be that the bond be vlan challenged until the first slave is added to the team.

I do not like the idea of the vlan module listening to netdev events and updating its mac address accordingly since in my opinion the proper way is to have the settings of the slave change according to the master's and not the opposite i.e. once a user configures a vlan interface over a device he should not be changing the device settings but rather propagating the settings down from the vlan interface (as we do for bond masters and slaves).

As for the boot problem, we would have to find a way to get the vlans to come up only after the slaves (but not lexicographically dependant)

Tsippy

-----Original Message-----
From: Hen, Shmulik 
Sent: Monday, September 15, 2003 4:42 PM
To: bonding-devel@lists.sourceforge.net; netdev@oss.sgi.com
Cc: Noam, Amir; Hen, Shmulik; Mendelson, Tsippy; naom.marom@intel.com
Subject: Problems using bonding with vlan


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
