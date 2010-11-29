From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: biosdevname v0.3.1
Date: Sun, 28 Nov 2010 22:48:04 -0600
Message-ID: <20101129044804.GB29904@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	"K, Narendra" <Narendra_K@Dell.com>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	Co
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:6271 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754809Ab0K2EsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 23:48:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've published biosdevname v0.3.1.  This has quite a few changes since
the 0.2.4 version published over 3 years ago.  Grab it here:

http://linux.dell.com/files/biosdevname/permalink/biosdevname-0.3.1.tar.gz
http://linux.dell.com/files/biosdevname/permalink/biosdevname-0.3.1.tar.gz.sign
GIT: http://linux.dell.com/cgi-bin/gitweb/gitweb.cgi?p=biosdevname.git;a=summary

Highlights:
- uses sysfs index and SMBIOS information if available.
- The only policies that remain are the new default 'physical' policy
  that uses sysfs index (SMBIOS), and the historic all_ethN policy
  that is only usable in non-hotplug environments.
- works on SR-IOV devices as well as traditional NICs

The naming policy it suggests are as follows:

Embedded devices: em<port>
Add-in PCI cards: pci<slot>#<port>_<virtual function instance>

My goal is to get this into Fedora 15, RHEL 6.x (x TBD), Debian, Ubuntu Natty,
openSUSE, and any other distribution that will have it.



git shortlog:

Gabriel C (1):
      add make uninstall target

Jordan Hargrave (2):
      fix mmap() return check
      bump version

Matt Domsch (72):
      Fix 'make deb' so it works.
      add 'make sdeb' for source debian packages for review
      include pkg/debian/ in tarball
      rpm specs: manpages are sometimes automatically compressed
      rpm spec: fix manpage in %files, add udev version requirement for Fedora
      update Makefile.in
      add chassis_label field
      add smbios_names naming policy
      ensure display buffer is long enough and zeroed before use
      bug fix: s/sprintf/snprintf/ leading to SEGV
      dmidecode: get proper chassis label string
      naming_policy: fix smbios_names reporting
      exit with error code if --policy=smbios_names but BIOS doesn't have the info
      make dev->bios_name[] a pointer
      udev rules: don't rename, create symlinks in net/by-slot-name and net/by-chassis-label instead
      strip trailing whitespace from SMBIOS strings
      remove extra spaces in udev rules, to work around udev bug
      add intermediary program /lib/udev/netdevice to cycle through biosdevname policies
      finish fixing up configure/Makefiles
      start netdevnames at 71; make netdevice exectuable
      s/chassis_label/smbios_label/
      move sysfs reading function from pcmcia to its own file
      read sysfs label and index files for PCI devices
      minor cleanups; dead code removal
      remove generated files from source control
      configure: note requires pciutils-devel
      read label and index from sysfs if present
      add policy=loms, make it default
      add .gitignore
      silently handle running in virtualization, bug fix storing sysfs label
      better configure messages on missing zlib-devel and pciutils-devel
      fix buglet in add_interface, with thanks to gcc 4.4.5 -Wall
      don't use perror() to print meaningless warnings to users
      don't print error opening /dev/mem, as fails on KVM guests
      bugfixes in reading sysfs files
      invoke biosdevname directly from udev rule, --policy=loms
      remove the netdevice script from install
      add policy=loms to manpage
      fix Makefile uninstall-local failure
      fix udev rules typo
      finish removing netdevice script
      update changelogs, bump version
      rename policy=loms to =embedded, use enX instead of lomX
      make embedded NIC name configurable, default ='en'
      add --prefix to manpage
      Use sysfs to find parent devices and slot
      add --policy=pony (to be renamed later) naming of PCI devices
      attach VFs to PFs, unparse the lists when debugging
      assign names to PCI VFs as pci1#0_2 for slot 1, port 0, VF 2
      change default embedded prefix to "em"
      allow all combinations of embedded/add-in, PF or VF, in naming
      don't use #port nomenclature for embedded devices
      mark HP embedded NICs as being embedded
      remove unused function
      s/pony/physical/
      fix udev rule policy name
      change udev rule to set NAME=, so stateful names persistent names aren't written to 70-persistent-net.rules
      add additional checks and define _GNU_SOURCE in configure.ac
      get VF index from sysfs
      fix getting VF indices from sysfs
      more fixes for SRIOV detection
      move setting slot_index into pci.c, fixes failures with SR-IOV devices; other cleanups.
      don't print to stderr on SIOCGIFHWADDR failure
      note that index_in_slot is only valid for physical slot PF devices
      POLICY DELETIONS: delete all policies but all_ethN and physical (default)
      only print Index in slot where it's valid
      fix manpage for policy deletions
      clean up manpage and help text
      fix use of uses_smbios
      update manpage with the naming policies in use now
      document return codes in manpage
      bump version string to 0.3.1


Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
