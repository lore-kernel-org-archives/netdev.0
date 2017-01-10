From: Hannes Reinecke <hare@suse.de>
Subject: Re: [Open-FCoE] [PATCH RFC 2/5] qedf: Add QLogic FastLinQ offload
 FCoE driver framework.
Date: Tue, 10 Jan 2017 07:56:25 +0100
Message-ID: <0bf96a63-4d13-64f2-1f3b-880912c5d331@suse.de>
References: <1482520628-24207-1-git-send-email-chad.dupuis@cavium.com>
 <1482520628-24207-3-git-send-email-chad.dupuis@cavium.com>
 <7df11d77-df7b-af58-2646-e92cdbba2146@suse.de>
 <alpine.OSX.2.00.1701091141550.1044@administrators-macbook-pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: martin.petersen@oracle.com, fcoe-devel@open-fcoe.org,
        netdev@vger.kernel.org, QLogic-Storage-Upstream@cavium.com,
        linux-scsi@vger.kernel.org, yuval.mintz@cavium.com
To: Chad Dupuis <chad.dupuis@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51079 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1765133AbdAJG42 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 01:56:28 -0500
In-Reply-To: <alpine.OSX.2.00.1701091141550.1044@administrators-macbook-pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/2017 05:45 PM, Chad Dupuis wrote:
> 
> On Wed, 28 Dec 2016, 9:00am -0000, Hannes Reinecke wrote:
> 
>> On 12/23/2016 08:17 PM, Dupuis, Chad wrote:
>>> From: "Dupuis, Chad" <chad.dupuis@cavium.com>
>>>
>>> The QLogic FastLinQ Driver for FCoE (qedf) is the FCoE specific module
>>> for 41000 Series Converged Network Adapters by QLogic.
>>>
>>> This patch consists of following changes:
>>>   - MAINTAINERS Makefile and Kconfig changes for qedf
>>>   - PCI driver registration
>>>   - libfc/fcoe host level initialization
>>>   - SCSI host template initialization and callbacks
>>>   - Debugfs and log level infrastructure
>>>   - Link handling
>>>   - Firmware interface structures
>>>   - QED core module initialization
>>>   - Light L2 interface callbacks
>>>
>>> Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
>>> Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
>>> Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
>>> Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
>>> ---
>>>  MAINTAINERS                      |    6 +
>>>  drivers/scsi/Kconfig             |    1 +
>>>  drivers/scsi/qedf/Kconfig        |   11 +
>>>  drivers/scsi/qedf/Makefile       |    5 +
>>>  drivers/scsi/qedf/qedf.h         |  555 ++++++
>>>  drivers/scsi/qedf/qedf_attr.c    |  165 ++
>>>  drivers/scsi/qedf/qedf_dbg.c     |  192 +++
>>>  drivers/scsi/qedf/qedf_dbg.h     |  153 ++
>>>  drivers/scsi/qedf/qedf_debugfs.c |  472 +++++
>>>  drivers/scsi/qedf/qedf_main.c    | 3519 ++++++++++++++++++++++++++++++++++++++
>>>  drivers/scsi/qedf/qedf_version.h |   15 +
>>>  11 files changed, 5094 insertions(+)
>>>  create mode 100644 drivers/scsi/qedf/Kconfig
>>>  create mode 100644 drivers/scsi/qedf/Makefile
>>>  create mode 100644 drivers/scsi/qedf/qedf.h
>>>  create mode 100644 drivers/scsi/qedf/qedf_attr.c
>>>  create mode 100644 drivers/scsi/qedf/qedf_dbg.c
>>>  create mode 100644 drivers/scsi/qedf/qedf_dbg.h
>>>  create mode 100644 drivers/scsi/qedf/qedf_debugfs.c
>>>  create mode 100644 drivers/scsi/qedf/qedf_main.c
>>>  create mode 100644 drivers/scsi/qedf/qedf_version.h
>>>
>> [ .. ]
>>> +/* Returns true if we have a valid vlan, false otherwise */
>>> +static bool qedf_initiate_fipvlan_req(struct qedf_ctx *qedf)
>>> +{
>>> +	int rc;
>>> +
>>> +	if (atomic_read(&qedf->link_state) != QEDF_LINK_UP) {
>>> +		QEDF_ERR(&(qedf->dbg_ctx), "Link not up.\n");
>>> +		return  false;
>>> +	}
>>> +
>>> +	while (qedf->fipvlan_retries--) {
>>> +		if (qedf->vlan_id > 0)
>>> +			return true;
>> Some weird FCoE bridges (most notably HP VirtualConnect) return a VLAN
>> ID of '0'. Shouldn't you rather test for '>= 0' here?
> 
> Will look into this but isn't a VLAN ID of 0 not valid?
> 
Well, a VLAN ID of '0' indicates no VLAN at all but rather use the base
interface.
But you still will be seeing a VLAN ID '0' in the FIP VLAN response.


Cheers,

Hannes
-- 
Dr. Hannes Reinecke		   Teamlead Storage & Networking
hare@suse.de			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: F. Imendörffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG Nürnberg)
