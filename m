From: "Anil Veerabhadrappa" <anilgv@broadcom.com>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Wed, 21 Nov 2007 10:38:16 -0800
Message-ID: <1195670296.8767.9.camel@dhcp-10-13-106-205.broadcom.com>
References: <1188599815.5176.12.camel@dell>
 <46DEF69D.3090901@redhat.com>
 <1189027622.19638.42.camel@dhcp-10-13-106-205.broadcom.com>
 <46E1CF4B.9080407@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Mike Christie" <mchristi@redhat.com>,
	"Michael Chan" <mchan@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	talm@broadcom.com, lusinsky@broadcom.com, uri@broadcom.com,
	"SCSI Mailing List" <linux-scsi@vger.kernel.org>
To: "Mike Christie" <michaelc@cs.wisc.edu>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <46E1CF4B.9080407@cs.wisc.edu>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> >> The sysfs bits related to the hba should be use one of the scsi sysfs 
> >> facilities or if they are related to iscsi bits and are generic then 
> >> through the iscsi hba
> > 
> > bnx2i needs 2 sysfs entries -
> > 1. QP size info - this is used to size per connection shared data
> > structures to issue work requests to chip (login, scsi cmd, tmf, nopin)
> > and get completions from the chip (scsi completions, async messages,
> > etc'). This is a iSCSI HBA attribute
> > 2. port mapper - we can be more flexible on classifying this as either
> > iSCSI HBA attribute or bnx2i driver global attribute
> > Can hooks be added to iSCSI transport class to include these?
> > 
> 
> Which ones were they exactly? I think JamesB wanted only common 
> transport values in the transport class. If it is driver specific then 
> it should go on the host or target or device with the scsi_host_template 
> attrs.
> 

It's a chicken & egg issue to put "port mapper" sysfs entry in scsi host
attributes. Application won't see sysfs unless initiator creates an
iSCSI session and driver can't create an iSCSI session without a tcp
port. I was wondering if there is a better way than using IOCTL in this
situation?

