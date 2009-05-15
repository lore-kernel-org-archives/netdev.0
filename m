From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: KVM 10/Gb Ethernet PCIe passthrough with Linux/iSCSI and large
	block sizes
Date: Thu, 14 May 2009 21:29:21 -0700
Message-ID: <1242361761.21442.276.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"H. Peter Anvin" <hpa@zytor.com>, Hannes Reinecke <hare@suse.de>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Christoph Hellwig <hch@lst.de>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Sheng Yang <sheng@linux.intel.com>,
	Leonid Grossman <leonid.grossman@neterion.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>
To: kvm-devel <kvm@vger.kernel.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	Linux-netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings all,

The first test results for Linux/iSCSI Initiators and targets for large
block sizes using 10 Gb/sec Ethernet + PCIe device-passthrough into
Linux/KVM guests have been posted at:

http://linux-iscsi.org/index.php/KVM-LIO-Target

So far, the results have been quite impressive using the Neterion X3100
series hardware with recent KVM-85 stable code (with Marcelo's patches,
see the above link) on v2.6.29.2 KVM guests, and using v2.6.30-rc3 KVM
Hosts.

Using iSCSI RFC defined MC/S to scale a *single* KVM accessable
Linux/iSCSI Logical Unit to 10 Gb/sec line-rate speeds has been
successful using Core-iSCSI WRITE/READ (bi-directional) traffic using
Linux-Test-Project disktest pthreaded benchmark with O_DIRECT enabled.
Using Core-iSCSI MC/S w/ iSCSI READ (uni-directional) the average is
about 6-7 Gb/sec, and with MC/S iSCSI WRITE (uni-directional) the
average is about 5 Gb/sec to the RAMDISK_DR and FILEIO storage objects
for these same streaming tests.  Please see the link for more
information on the tests and hardware/software setup.

The tests have been run with both upstream Open-iSCSI and Core-iSCSI
Initiators against Target_Core_Mod/LIO-Target v3.0 in KVM guests.  It is
important to note that these tests have been run with tcp_sendpage()
disabled (tcp_sendpage() is enabled by default in LIO-Target and
Open-iSCSI) in 10 Gb/sec KVM guests, which have been disable into order
to get up running with the 10 Gb/sec hardware.  1 Gb/sec e1000e ports
are stable with sendpage() in LIO-Target KVM guests, and these will be
enabled in 10 Gb/sec hardware in subsequent tests.  Also note that
Open-iSCSI WRITEs using tcp_sendpage() have been ommited for this first
run of tests.

It is also important to note that both iSCSI MC/S and dm-multipath are
methods to allow a single Linux/SCSI Logical Unit to scale across
multiple TCP connections using the iSCSI Protocol.  Both of these
methods (iSCSI RFC fabric level multiplexing and OS-level SCSI
Multipath) allow for means for scaling across multiple X3110 Vpaths
(MSI-X TX/RX pairs), and MC/S is a method that has a low amount of
overhead.

Some of the future setups for KVM + 10 Gb/sec will be using dm-multipath
block devices, 10 Gb/sec Ethernet PCIe multi-function mode into KVM
guest, as well as PCIe SR-IOV on recent IOMMU capable hardware
platforms.

Many thanks to the Neterion folks and Sheng Yang for answering my
questions!

--nab


