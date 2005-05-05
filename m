From: Alex Aizman <itn780@yahoo.com>
Subject: [ANNOUNCE] Linux-iSCSI High-Performance Initiator
Date: Wed, 04 May 2005 21:31:33 -0700
Message-ID: <4279A1A5.60405@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	linux-iscsi-devel@lists.sourceforge.net,
	open-iscsi@googlegroups.com,
	James Bottomley <James.Bottomley@SteelEye.com>,
	Christoph Hellwig <hch@lst.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
To: linux-scsi@vger.kernel.org
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. Linux iSCSI Initiator
=================
This is to announce a new release of the iSCSI Initiator for Linux: 
v5.0.0.3rc2 for 2.6.12 kernel. The previous (2nd) submission (posted 
04/12/05) can be located at:

http://marc.theaimsgroup.com/?l=linux-kernel&m=111328256211837&w=2

The very first submission is here:

http://marc.theaimsgroup.com/?l=linux-kernel&m=111017939025775&w=2

Current release is result of the ongoing effort by the combined 
linux-iscsi team. In-depth information on the project, including the 
latest download, performance results, etc. documentation can be found at:

http://linux-iscsi.sourceforge.net

and/or

http://www.open-iscsi.org


2. SCSI transport
=============
This Initiator will work with the new iSCSI transport class from the 
(very) recent submission by Mike Christie. The related (and required) 
submission can be located at:

http://marc.theaimsgroup.com/?l=linux-kernel&m=111526182523809&w=2

3. The patch
=========

A single consolidated (94KB) patch against 2.6.12 can be downloaded at:

http://www.open-iscsi.org/src/iscsi_tcp.patch

This contains:
 
                - SCSI LLDD: iscsi_tcp.[ch] (iSCSI transport over TCP/IP).
                - drivers/scsi/Kconfig changes
                - drivers/scsi/Makefile changes

                Signed-off-by: Alex Aizman <itn780@yahoo.com>
                Signed-off-by: Dmitry Yusupov <dmitry_yus@yahoo.com>


4. User space
==========
The assoicated userspace tools can be downloaded from 
http://www.open-iscsi.org/index.html#download


5. Changelog since v5.0.0.2 (Open-iSCSI v 0.2)
===================================
* support non-immediate control plane commands
* flush queue in cnx_stop()
* fix queue add/remove
* Christoph Hellwig:
  - remove sys_iopl and <sys/io.h> (no need since oom_adj serves the 
purpose)
  - patch to use __be16/__be16 types for static typechecking with sparse 
-Wbitwise
  - make needlessly global symbols static
  - switch to proper goto-based error unwinding
  - kill zone_init cpp abuse
  - lots of 0 vs. NULL and one missing void in a prototype: cleanup
  - make two needlessly global symbols in iscsi_tcp.c static
  - use uintptr_t (the C99 type) to store a pointer instead of the 
locally defined ulong_t
* Mike Christie:
  - scsi_host_lookup: release scsi host handle right away
  - patch to move the scsi scanning to userspace.
  - request_bufflen: rely on the scsi_ml to set the correct value
  (INQUIRY, REQUEST_SENSE and REPORT_LUNS etc.)
* data_xmit(): cleanup, optimization
* MRDSL fix (discovered by Mike Christie)
* use GFP_ATOMIC in case of recovery and GFP_KERNEL in case of initial login
* race fix: max_r2t data_xmit() vs. r2t_rsp()
* release socket cleanup: done _after_ stopping data_xmit()
* padding: scsi_cmnd total length
* r2t sglist assertion fixes
* deprecate and remove control plane cnx/snx handles
* ERL=0 recovery fix for HeaderDigest=CRC32C
* iSCSI MIB and extended statistics: initial support, get_stats() API
* get_stats(): calculate actual size of statistics buffer
* integrate with scsi_transport_iscsi.[ch]


Regards,

Linux-iscsi Team
