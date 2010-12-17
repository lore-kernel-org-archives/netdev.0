From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: biosdevname v0.3.4
Date: Thu, 16 Dec 2010 23:06:25 -0600
Message-ID: <20101217050625.GA32577@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	"K, Narendra" <Narendra_K@Dell.com>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	Co
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

biosdevname, now version 0.3.4.

The main visible change is that port indices now start at 1 rather
than 0, when assigned by biosdevname (such as falling back to PIRQ)
rather explicitly assigned by BIOS.  This is in keeping with how the
indices are assigned by BIOS on Dell and HP servers.


em<port>         where port starts at 1
pci<slot>#<port> where port starts at 1

As a side effect, the first VMware Workstation guest NIC now appears as pci3#1
because the virtual machine BIOS exposes the device as being in a PCI
slot via PIRQ.


This also drops an explicit dependency check on a particular udev
version.  That version was supposed to properly handle parallel
conflicting renames when swizzling within the ethX namespace, but as
we've discovered, that doesn't always work.  The udev in RHEL5 is
older than what we were specifying, but it works just fine, so no more
check.

Furthermore, if biosdevname somehow messes up (either through its own
bug or because of a buggy BIOS), and would assign the same name to two
different devices, it won't try to assign names to either (who knows
which is correct?).  You can see the duplciates when running with the
-d debug option.


Grab it here:
http://linux.dell.com/files/biosdevname/permalink/biosdevname-0.3.4.tar.gz
http://linux.dell.com/files/biosdevname/permalink/biosdevname-0.3.4.tar.gz.sign
git://linux.dell.com/biosdevname.git

I built this today for Fedora rawhide (will be 15), and I encourage
other distributions to pick it up as well.

shortlog:

Matt Domsch (5):
      require any udev
      Return nothing if duplicate names would be assigned.
      Don't assign names to unknown devices
      only supress duplicates, not all names if any duplicates exist
      start with port index 1, not index 0


Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
