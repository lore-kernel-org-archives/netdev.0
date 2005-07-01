From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.13-rc1 0/17] bonding: Sysfs Support
Date: Fri, 1 Jul 2005 13:22:05 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0507011313500.17459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   This patch set is an updated sysfs bonding patch to the one sent
previously in April. The patch is upto date with all recent bonding
and kernel changes and applies cleanly to linux-2.6.13-rc1. It adds
sysfs entry for the "Xmit Hash Policy" for new bonding module param;
incorporates feedback and bug fixes on all known issues and has been
tested on linux-2.6.13-rc1.

   The interface is pretty simple. Here are some notes on how it could be 
used:

   The file /sys/class/net/bonding_masters contains the names of all the
active bonds. To add or remove bonds, write a whitespace-delimited list of
interface names to this file.  For example:

echo "bond1 bond2 bond3" > /sys/class/net/bonding_masters

will create three bonds with the given names.  If any other bonds exist,
they will be deleted.

echo "bond0 bond2 bond3" > /sys/class/net/bonding_masters

would then create bond0 and remove bond1.

   For each bond, there is a directory /sys/class/net/<bondname>/bonding.
In this directory are a number of files which control the bond.  The names
of these files match the existing module parameters and do the same 
things.

   The slaves file contains a whitespace-delimited list of interface names,
  which are slaves to the bond.  This file behaves much the same as the
"bonding_masters" file; just write a list of your desired interfaces to
this file.

   Likewise, the arp_targets file contains a whitespace-delimited list of 
IP addresses and should be written to in a similar fashion.

   The other files contain single values(numeric and/or mnemonic).

   Some caveats:
    - slaves can only be assigned when the interface is up
    - mode can only be changed when the interface is down
    - Xmit hash policy can be changed only when interface is down

   Warnings and status messages will be logged and can be viewed with dmesg.

   Example:
   modprobe bonding
   echo "bond0 bond1" > /sys/class/net/bonding_masters
   echo "6" > /sys/class/net/bond0/bonding/mode
   echo "1000" > /sys/class/net/bond0/bonding/miimon
   ifconfig bond0 192.168.0.1
   echo "eth0 eth1" > /sys/class/net/bond0/bonding/slaves
   # bond0 is now ready to use
   echo "1" > /sys/class/net/bond1/bonding/mode
   # ... and so on for bond1


  These patches were generated against 2.6.12 with Jay's upstream patches.
  It applies cleanly to kernel 2.6.13-rc1.

- Radheka Godse
- Mitch Williams
