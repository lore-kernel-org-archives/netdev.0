From: "Anil Veerabhadrappa" <anilgv@broadcom.com>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Tue, 27 Nov 2007 16:44:51 -0800
Message-ID: <1196210691.5980.20.camel@dhcp-10-13-106-220.broadcom.com>
References: <1188599815.5176.12.camel@dell>
 <46DEF69D.3090901@redhat.com>
 <1189027622.19638.42.camel@dhcp-10-13-106-205.broadcom.com>
 <46E1CF4B.9080407@cs.wisc.edu>
 <1195670296.8767.9.camel@dhcp-10-13-106-205.broadcom.com>
 <474B99E8.8070402@cs.wisc.edu>
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
In-Reply-To: <474B99E8.8070402@cs.wisc.edu>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> >> Which ones were they exactly? I think JamesB wanted only common 
> >> transport values in the transport class. If it is driver specific then 
> >> it should go on the host or target or device with the scsi_host_template 
> >> attrs.
> >>
> > 
> > It's a chicken & egg issue to put "port mapper" sysfs entry in scsi host
> > attributes. Application won't see sysfs unless initiator creates an
> 
> Sorry for the late response. I was on vacation.
> 
> That is only with how you coded it today. I asked you to do something 
> like qla4xxx where the session and host are not so closely bound.

bnx2i is still using scsi host per iscsi session model, we plan to
migrate to scsi host per device model pretty soon. Previously you
indicated that you are working on this port, can you please share the
code? We will build on your work and bring this to closure.


> 
> > iSCSI session and driver can't create an iSCSI session without a tcp
> 
> That is not right with how things are today even. The iscsi_session 
> struct can be created before the tcp connection. This was done because 
> we thought we were going to have to use only sysfs for all setup and 
> management (we ended up netlink and sysfs though).

You are right, software is flexible enough to allow creation of
session/connection and endpoint independently but so far user daemon
creates TCP endpoint before iSCSI session and bind them all together.
Any changes to this scheme will not be compatible with existing
distributions



