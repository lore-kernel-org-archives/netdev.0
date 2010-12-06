From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: biosdevname v0.3.2
Date: Mon, 6 Dec 2010 08:06:50 -0600
Message-ID: <20101206140649.GA13628@auslistsprd01.us.dell.com>
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

Bugfix update to biosdevname, now version 0.3.2.

The legacy code for reading the PCI IRQ Routing Table ($PIR) and the
PCMCIA information has been removed.  This means biosdevname will only
report BIOS-provided names if your system has SMBIOS 2.6 or higher and
has the information in Type 9 or Type 41.  This is in preparation for
widespread use, and will keep biosdevname from suggesting names on
systems that are well into or beyond their useful lifetime and
introducing an unexpected change of behavior on them.  Dell PowerEdge
10G and newer, HP ProLiant G6 and newer are known to have SMBIOS 2.6,
as do a number of desktop, laptop, and netbook-class systems as
reported on the fedora-devel mailing list.

This release also provides correct names for Intel and Broadcom
quad-port GigE cards that I've tried.  Format is pci<slot>#<port>.

Grab it here:
http://linux.dell.com/files/biosdevname/permalink/biosdevname-0.3.2.tar.gz
http://linux.dell.com/files/biosdevname/permalink/biosdevname-0.3.2.tar.gz.sign
git://linux.dell.com/biosdevname.git

This is already built in Fedora rawhide (will be 15), and I encourage
other distributions to pick it up as well.

On a related note, I've submitted a patch to dracut upstream to
include calls to biosdevname via udev.  This will let us use
BIOS-suggested names for network functionality during initramfs time,
such as finding your root file system on NFS or iSCSI.


Shortlog:

Matt Domsch (7):
      only match on smbios_type Ethernet, ignore sysfs index file for now
      PIRQ-ectomy, add pci_access pointer to state, pci_dev pointer instead of struct in pci_device
      PCMCIA-ectomy
      copy SMBIOS slot info to all matching domain/bus/device/functions
      skip bridges when setting index_in_slot
      fix RPM spec URL
      bump version


Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
