From: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Wed, 28 Nov 2007 14:06:28 -0600
Message-ID: <474DCA44.7030901@cs.wisc.edu>
References: <1188599815.5176.12.camel@dell> <46DEF69D.3090901@redhat.com> <1189027622.19638.42.camel@dhcp-10-13-106-205.broadcom.com> <46E1CF4B.9080407@cs.wisc.edu> <1195670296.8767.9.camel@dhcp-10-13-106-205.broadcom.com> <474B99E8.8070402@cs.wisc.edu> <1196210691.5980.20.camel@dhcp-10-13-106-220.broadcom.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mike Christie <mchristi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michael Chan <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, talm-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, lusinsky-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, uri-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, SCSI Mailing List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1196210691.5980.20.camel-opBMJL+S1+mb6IhXEaeG+20Cxg0+/0ngpWgKQ6/u3Fg@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi-help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi-unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


Anil Veerabhadrappa wrote:
> 
>>>> Which ones were they exactly? I think JamesB wanted only common 
>>>> transport values in the transport class. If it is driver specific then 
>>>> it should go on the host or target or device with the scsi_host_template 
>>>> attrs.
>>>>
>>> It's a chicken & egg issue to put "port mapper" sysfs entry in scsi host
>>> attributes. Application won't see sysfs unless initiator creates an
>> Sorry for the late response. I was on vacation.
>>
>> That is only with how you coded it today. I asked you to do something 
>> like qla4xxx where the session and host are not so closely bound.
> 
> bnx2i is still using scsi host per iscsi session model, we plan to
> migrate to scsi host per device model pretty soon. Previously you
> indicated that you are working on this port, can you please share the
> code? We will build on your work and bring this to closure.

Send me a link to your code so I can rebuild my stuff against it.

> 
> 
>>> iSCSI session and driver can't create an iSCSI session without a tcp
>> That is not right with how things are today even. The iscsi_session 
>> struct can be created before the tcp connection. This was done because 
>> we thought we were going to have to use only sysfs for all setup and 
>> management (we ended up netlink and sysfs though).
> 
> You are right, software is flexible enough to allow creation of
> session/connection and endpoint independently but so far user daemon
> creates TCP endpoint before iSCSI session and bind them all together.
> Any changes to this scheme will not be compatible with existing
> distributions
> 

So what do you need to do exactly? You want userspace to be able to set 
some session or connection value, then have it used for that session, 
right? We have been using the netlink interface for that. You would 
basically pass iscsiadm some value (on cmdline or in some file/db), then 
when the session and connection is being created we will pass those 
values in. Values that are used after we are in FFP, like abort 
timeouts, are passed in the set_param command. If a value is needed for 
the session/connection setup then we were passing that in with the 
command (like create_session has the queue depth sent with it). To add 
new values (driver specific and common ones) and have the interface 
compatible with older versions should not be too difficult.

--~--~---------~--~----~------------~-------~--~----~
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To unsubscribe from this group, send email to open-iscsi-unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi
-~----------~----~----~----~------~----~------~--~---
