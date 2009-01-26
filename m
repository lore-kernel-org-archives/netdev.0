From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [ANNOUNCE]: lio-core-2.6.git updated to v2.6.29-rc2
Date: Mon, 26 Jan 2009 12:23:18 -0800
Message-ID: <1233001398.6442.48.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	Douglas Gilbert <dgilbert@interlog.com>,
	Andrew Morton <akpm@osdl.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Christoph Hellwig <hch@infradead.org>,
	Ming Zhang <blackmagic02881@gmail.com>,
	"Ross S. W. Walker" <rswwalker@gmail.com>,
	Arne Redlich <agr@powerkom-dd.de>,
	Rafiu Fakunle <rafiu@openfiler.com>,
	Hannes Reinecke <hare@suse.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Greg KH <greg@kroah.com>, Joel Becker <joel.becker@oracle.com>
To: "Linux-iSCSI.org Target Dev"
	<linux-iscsi-target-dev@googlegroups.com>,
	Linux-netdev <netdev@vger.kernel.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings all,

The lio-core-2.6.git tree for Target_Core_Mod/ConfigFS (generic storage
engine) and LIO-Target/ConfigFS v3.0 (Linux-iSCSI target stack) have
been updated to v2.6.29-rc2 and tested on 32-bit x86 HVM using
Open/iSCSI for Linux/TCP and Core-iSCSI using Linux/SCTP as iSCSI
Initiators.

The git tree is located on kernel.org at:

http://git.kernel.org/?p=linux/kernel/git/nab/lio-core-2.6.git;a=summary

You can find more information about the projects at:

http://linux-iscsi.org/index.php/LIO-Target
http://linux-iscsi.org/index.php/LIO-Target/ConfigFS
http://linux-iscsi.org/index.php/Target_Core_Mod/ConfigFS

Recent work for Target_Core_Mod includes a WIP SPC-3 compliant
PERSISTENT RESERVE implementation that is ConfigFS aware for all
Subsystems plugins (PSCSI, IBLOCK, FILEIO, RAMDISK) and all potential
$FABRIC_MODs has the infrastructure, legacy SPC-2 reservations is up and
running, and very first logic up for PERSISTENT RESERVE running+tested
against Doug Gilbert's sg3_utils package.  Also, T10 EVPD emulation has
been included in the recent work to allow for user defined EVPD Unit
Serial emualation when no Unit Serial information is available via the
device server firmware.

Here is what it looks like running on v2.6.29-rc2 doing various SPC-3
PERSISTENT_RESERVE+SA:REGISTER across LIO-Target v3.0 iSCSI/SCTP fabric
(Stream Control Transmission Protocol):

<SNIP>

TARGET_CORE[0]: Loading Generic Kernel Storage Engine: v3.0.0 on Linux/i686 on 2.6.29-rc2
TARGET_CORE[0]: Initialized ConfigFS Fabric Infrastructure: v1.0.0 on Linux/i686 on 2.6.29-rc2

<SNIP>

Target_Core_ConfigFS: REGISTER -> group: d1f29400 name: iscsi
Linux-iSCSI.org iSCSI Target Core Stack v3.0.0 on Linux/i686 on 2.6.29-rc2
SE: fp_auto_assign: 0
<<<<<<<<<<<<<<<<<<<<<< BEGIN FABRIC API >>>>>>>>>>>>>>>>>>>>>>
Initialized struct target_fabric_configfs: c8d5aa00 for iscsi
<<<<<<<<<<<<<<<<<<<<<< END FABRIC API >>>>>>>>>>>>>>>>>>>>>>
LIO_TARGET[0] - Set fabric -> lio_target_fabric_configfs

<SNIP>

Received iSCSI login request from 172.16.201.129 on SCTP Network Portal 172.16.201.128:3260
Located Storage Object: iqn.2003-01.org.linux-iscsi.target.i686:sn.e475ed6fcdd0
TARGET_CORE[iSCSI]: Registered fabric_sess_ptr: cc55c000
iSCSI Login successful on CID: 0 from 172.16.201.129 to 172.16.201.128:3260,1
Incremented iSCSI Connection count to 1 from node: iqn.1993-08.org.debian:01:2dadf92d0ef
Established iSCSI session from node: iqn.1993-08.org.debian:01:2dadf92d0ef
Incremented number of active iSCSI sessions to 1 on iSCSI Target Portal Group: 1

<SNIP>

SPC-3 PR [iSCSI] Service Action: REGISTER Initiator Node: iqn.1993-08.org.debian:01:2dadf92d0ef
SPC-3 PR [iSCSI] for SINGLE TCM Subsystem iblock Object Port(s)
SPC-3 PR [iSCSI] SA Res Key: 0x000000005678efff PRgeneration: 0x00000000
SPC-3 PR [iSCSI] REGISTER: Changed Reservation Key for iqn.1993-08.org.debian:01:2dadf92d0ef to: 0x000000001234abcd PRgeneration: 0x00000001
SPC-3 PR [iSCSI] Service Action: UNREGISTER Initiator Node: iqn.1993-08.org.debian:01:2dadf92d0ef
SPC-3 PR [iSCSI] for SINGLE TCM Subsystem iblock Object Port(s)
SPC-3 PR [iSCSI] SA Res Key: 0x000000001234abcd PRgeneration: 0x00000001

<SNIP>

target:~# cat /proc/net/sctp/snmp 
SctpCurrEstab                   	1
SctpActiveEstabs                	0
SctpPassiveEstabs               	2
SctpAborteds                    	0
SctpShutdowns                   	1
SctpOutOfBlues                  	1
SctpChecksumErrors              	0
SctpOutCtrlChunks               	196
SctpOutOrderChunks              	461
SctpOutUnorderChunks            	0
SctpInCtrlChunks                	375
SctpInOrderChunks               	216
SctpInUnorderChunks             	0
SctpFragUsrMsgs                 	82
SctpReasmUsrMsgs                	0
SctpOutSCTPPacks                	611
SctpInSCTPPacks                 	539
SctpT1InitExpireds              	0
SctpT1CookieExpireds            	0
SctpT2ShutdownExpireds          	0
SctpT3RtxExpireds               	0
SctpT4RtoExpireds               	0
SctpT5ShutdownGuardExpireds     	0
SctpDelaySackExpireds           	173
SctpAutocloseExpireds           	0
SctpT3Retransmits               	0
SctpPmtudRetransmits            	0
SctpFastRetransmits             	0
SctpInPktSoftirq                	486
SctpInPktBacklog                	52
SctpInPktDiscards               	1
SctpInDataChunkDiscards         	0

There are many more patches coming, so please keep watching the
LIO-devel list, here are the recent series of patches for those
interested:

For the T10 EVPD Unit Serial Emulation and firmware EVPD ConfigFS
infrastructure:

[PATCH 0/2] [Target_Core_Mod]: Add EVPD information to ConfigFS
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/87a5e53d8e03361d#
[PATCH 1/2] [Target_Core_Mod]: Move 10_wwn_t to se_subsystem_dev_t->t10_wwn
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/9ea13ba51c8c06d2#
[PATCH 2/2] [Target_Core_Mod/ConfigFS]: Add T10 EVPD / WWN storage object attributes
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/8b00d47f0c182b00#

[PATCH 0/6} [Target_Core_Mod]: Add T10 EVPD Unit Serial Number Emulation
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/a200761da608df7c#
[PATCH 1/6] [Target_Core_Mod]: Add support for configurable EVPD Unit Serial Numbers
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/9b864c6f1ab27b9f#
[PATCH 2/6] [Target_Core_Mod/RAMDISK]: Update transport_generic_emulate_inquiry() usage
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/d2151ac814c58ce1#
[PATCH 3/6] [Target_Core_Mod/FILEIO): Update for EVPD and remove legacy parameter code
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/978c30be60f59553#
[PATCH 4/6] [Target_Core_Mod/IBLOCK): Update for EVPD and remove legacy parameter code
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/61f580bddf2841ab#
[PATCH 5/6] [Target_Core_Mod/pSCSI]: Update EVPD post processing logic
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/be7dbad6b1c4c1e9#
[PATCH 6/6] [Target_Core_Mod/ConfigFS]: Add support for $STORAGE_OBJECT EVPD Unit Serial Number emulation
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/84883354416151f5#

For the SPC-3 compliant PERSISTENT_RESERVATION emulation WIP: 

[PATCH 0/4] [Target_Core_Mod]: Add SPC-3 reserverations infrastructure
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/766ec7a3fbaccc62#
[PATCH 1/4] [Linux/SCSI] Add support for SPC-4 CDBs referenced in Persisent Reservations Allowed/Confict Table
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/6cb6b346fdf5c6c6#
[PATCH 2/4] [Target_Core_Mod]: Update core code for new reservations infrastructure
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/1381750ca3e07a9f#
[PATCH 3/4] [Target_Core_Mod] Add generic >= SPC-3 and legacy SPC-2 infrastructure
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/aa952eb7130b340b#
[PATCH 4/4] [Target_Core_Mod/ConfigFS] Add target/core/$HBA/$STORAGE_OBJECT/pr for T10 reservations
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/b1f6dc50f771b8a1#

[PATCH 0/7] [Target_Core_Mod]: Add running PRIO SA RESERVE and PRIN SA READ_KEYS and SA READ_RESERVATION support
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/ad2b8943f433ca0c#
[PATCH 1/7] [Target_Core_Mod]: Add SPC-3 PERSISTENT_RESERVE_* Infrastrcture
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/b1468d8f0419d351#
[PATCH 2/7] [LIO-Target]: Convert iscsi_send_check_condition_and_sense -> transport_send_check_condition_and_sense(
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/f05711bc97b63469#
[PATCH 3/7] [Target_Core_Mod/RAMDISK]: Convert to use Linux/SCSI SCSI_2 define
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/7c38dda0e58c96a3#
[PATCH 4/7] [Target_Core_Mod/FILEIO]: Convert to use Linux/SCSI SCSI_2 define
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/9fd1bb623eb2c14a#
[PATCH 5/7] [Target_Core_Mod/IBLOCK]: Convert to use Linux/SCSI SCSI_3 define
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/b6112acbc33f56cb#
[PATCH 6/7] [Target_Core_Mod/PERSISTENT_RESERVATION]: Add Service Action REGISTER logic
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/fb5fd76efb7cc883#
[PATCH 7/7] [Target_Core_Mod/ConfigFS]: Add res_pr_all_tgt_pts, res_pr_generation and res_pr_registered_i_pts
http://groups.google.com/group/linux-iscsi-target-dev/browse_thread/thread/26d2298eebc45c71#

--nab




