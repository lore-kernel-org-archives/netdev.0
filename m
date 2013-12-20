From: vaughan <vaughan.cao@oracle.com>
Subject: error message: VF is not privileged to issue opcode 89-1
Date: Fri, 20 Dec 2013 17:44:51 +0800
Message-ID: <52B41193.6020908@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: vaughan <vaughan.cao@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18225 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754789Ab3LTJlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 04:41:19 -0500
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id rBK9fIVE016850
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 09:41:19 GMT
Received: from userz7021.oracle.com (userz7021.oracle.com [156.151.31.85])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id rBK9fGqP006355
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 09:41:17 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userz7021.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id rBK9fGsa013727
	for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 09:41:16 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi experts,

I encounter the following error when creating SR-IOV VF for Emulex 10GB
nic on 3.8.13 kernel.

# modprobe be2net num_vfs=4
 be2net 0000:30:00.0: irq 214 for MSI/MSI-X
 be2net 0000:30:00.0: enabled 1 MSI-x vector(s)
 be2net 0000:30:00.0: created 0 RSS queue(s) and 1 default RX queue
 be2net 0000:30:00.0: created 1 TX queue(s)
 pci 0000:30:04.0: [19a2:0710] type 00 class 0x020000
 pci 0000:30:04.1: [19a2:0710] type 00 class 0x020000
 pci 0000:30:04.2: [19a2:0710] type 00 class 0x020000
 pci 0000:30:04.3: [19a2:0710] type 00 class 0x020000
 be2net 0000:30:00.0: Emulex OneConnect(be3): PF  port 0
 be2net 0000:30:00.1: irq 215 for MSI/MSI-X
 be2net 0000:30:00.1: enabled 1 MSI-x vector(s)
 be2net 0000:30:00.1: created 0 RSS queue(s) and 1 default RX queue
 be2net 0000:30:00.1: created 1 TX queue(s)
 pci 0000:30:06.0: [19a2:0710] type 00 class 0x020000
 pci 0000:30:06.1: [19a2:0710] type 00 class 0x020000
 pci 0000:30:06.2: [19a2:0710] type 00 class 0x020000
 pci 0000:30:06.3: [19a2:0710] type 00 class 0x020000
 be2net 0000:30:00.1: Emulex OneConnect(be3): PF  port 1
 be2net 0000:30:04.0: enabling device (0140 -> 0142)
 be2net 0000:30:04.0: Could not use PCIe error reporting
 be2net 0000:30:04.0: VF is not privileged to issue opcode 89-1
 be2net 0000:30:04.0: VF is not privileged to issue opcode 125-1
 be2net 0000:30:04.0: irq 216 for MSI/MSI-X
 be2net 0000:30:04.0: enabled 1 MSI-x vector(s)
 be2net 0000:30:04.0: created 0 RSS queue(s) and 1 default RX queue
 be2net 0000:30:04.0: created 1 TX queue(s)
 be2net 0000:30:04.0: VF is not privileged to issue opcode 34-1
 be2net 0000:30:04.0: Exhausted multicast HW filters.
 be2net 0000:30:04.0: Disabling HW multicast filtering.
 be2net 0000:30:04.0: VF is not privileged to issue opcode 34-1
 be2net 0000:30:04.0: Emulex OneConnect(be3): VF  port 0
...

But the module gets loaded and VFs are created.
Also when the module is unloaded, below errors are seen in syslog:
  be2net 0000:30:04.0: VF is not privileged to issue opcode 89-1

I checked the code, this error occurs in be_probe() and the error opcode
89 is OPCODE_COMMON_SET_INTERRUPT_ENABLE, which is essential for an
initializing process IMO. And I also found this thread
https://lkml.org/lkml/2013/5/14/690, which shows there is a bug that VFs
will be probed before PFs. According to this thread, I guess I may
encountered the same error.
Anyone can confirm if this is a real error like I guess? Thanks.


-- 
Regards,
Vaughan
