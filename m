From: "Anil Veerabhadrappa" <anilgv@broadcom.com>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Wed, 28 Nov 2007 16:36:25 -0800
Message-ID: <1196296585.13497.35.camel@dhcp-10-13-106-220.broadcom.com>
References: <1188599815.5176.12.camel@dell>
 <46DEF69D.3090901@redhat.com>
 <1189027622.19638.42.camel@dhcp-10-13-106-205.broadcom.com>
 <46E1CF4B.9080407@cs.wisc.edu>
 <1195670296.8767.9.camel@dhcp-10-13-106-205.broadcom.com>
 <474B99E8.8070402@cs.wisc.edu>
 <1196210691.5980.20.camel@dhcp-10-13-106-220.broadcom.com>
 <474DCA44.7030901@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Mike Christie" <mchristi@redhat.com>,
	"Michael Chan" <mchan@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org, talm@broadcom.com, lusinsky@broadcom.com,
	uri@broadcom.com, "SCSI Mailing List" <linux-scsi@vger.kernel.org>
To: open-iscsi@googlegroups.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <474DCA44.7030901@cs.wisc.edu>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-11-28 at 14:06 -0600, Mike Christie wrote:
> Anil Veerabhadrappa wrote:
> > 
> >>>> Which ones were they exactly? I think JamesB wanted only common 
> >>>> transport values in the transport class. If it is driver specific then 
> >>>> it should go on the host or target or device with the scsi_host_template 
> >>>> attrs.
> >>>>
> >>> It's a chicken & egg issue to put "port mapper" sysfs entry in scsi host
> >>> attributes. Application won't see sysfs unless initiator creates an
> >> Sorry for the late response. I was on vacation.
> >>
> >> That is only with how you coded it today. I asked you to do something 
> >> like qla4xxx where the session and host are not so closely bound.
> > 
> > bnx2i is still using scsi host per iscsi session model, we plan to
> > migrate to scsi host per device model pretty soon. Previously you
> > indicated that you are working on this port, can you please share the
> > code? We will build on your work and bring this to closure.
> 
> Send me a link to your code so I can rebuild my stuff against it.


ftp://Net_sys_anon@ftp1.broadcom.com/bnx2iscsi-2.6.25.diff



> > 
> > You are right, software is flexible enough to allow creation of
> > session/connection and endpoint independently but so far user daemon
> > creates TCP endpoint before iSCSI session and bind them all together.
> > Any changes to this scheme will not be compatible with existing
> > distributions
> > 
> 
> So what do you need to do exactly? You want userspace to be able to set 
> some session or connection value, then have it used for that session, 
> right? We have been using the netlink interface for that. You would 
> basically pass iscsiadm some value (on cmdline or in some file/db), then 
> when the session and connection is being created we will pass those 
> values in. Values that are used after we are in FFP, like abort 
> timeouts, are passed in the set_param command. If a value is needed for 
> the session/connection setup then we were passing that in with the 
> command (like create_session has the queue depth sent with it). To add 
> new values (driver specific and common ones) and have the interface 
> compatible with older versions should not be too difficult.

wondering how netlink interface can be expanded to assist hardware
vendor's in configuring and debugging offload devices. In addition to
the current issue we might use this interface for other device
configuration (e.g. administrator will have to shrink per connection
shared queue size if a large number of iSCSI connections is required)
and debugging purpose(e.g. get iSCSI connection context dump when an
error is detected on a connection). Former is a synchronous call while
later in most cases will complete asynchronously. This is how I image
the flow - 
vendor_config_apps --> iscsid --> netlink --> iscsi_transport --> driver

Also passing configuration info via cmd line or file/db will only work
for parameter types which are more like user preferences. I don't think
we will be able to specify a dynamic value using this mechanism, e.g.
port number could be different for 2 consecutive iscsi login to same
target. This will also break "-L all" interface, right?



> 
> --~--~---------~--~----~------------~-------~--~----~
> You received this message because you are subscribed to the Google Groups "open-iscsi" group.
> To post to this group, send email to open-iscsi@googlegroups.com
> To unsubscribe from this group, send email to open-iscsi-unsubscribe@googlegroups.com
> For more options, visit this group at http://groups.google.com/group/open-iscsi
> -~----------~----~----~----~------~----~------~--~---
> 
> 

