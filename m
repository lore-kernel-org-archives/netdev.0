From: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Mon, 26 Nov 2007 22:15:36 -0600
Message-ID: <474B99E8.8070402@cs.wisc.edu>
References: <1188599815.5176.12.camel@dell> <46DEF69D.3090901@redhat.com> <1189027622.19638.42.camel@dhcp-10-13-106-205.broadcom.com> <46E1CF4B.9080407@cs.wisc.edu> <1195670296.8767.9.camel@dhcp-10-13-106-205.broadcom.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mike Christie <mchristi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michael Chan <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, talm-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, lusinsky-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, uri-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, SCSI Mailing List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Anil Veerabhadrappa <anilgv-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1195670296.8767.9.camel-opBMJL+S1+mb6IhXEaeG+wpgy58w7zIFpWgKQ6/u3Fg@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi-help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi-unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


Anil Veerabhadrappa wrote:
>>>> The sysfs bits related to the hba should be use one of the scsi sysfs 
>>>> facilities or if they are related to iscsi bits and are generic then 
>>>> through the iscsi hba
>>> bnx2i needs 2 sysfs entries -
>>> 1. QP size info - this is used to size per connection shared data
>>> structures to issue work requests to chip (login, scsi cmd, tmf, nopin)
>>> and get completions from the chip (scsi completions, async messages,
>>> etc'). This is a iSCSI HBA attribute
>>> 2. port mapper - we can be more flexible on classifying this as either
>>> iSCSI HBA attribute or bnx2i driver global attribute
>>> Can hooks be added to iSCSI transport class to include these?
>>>
>> Which ones were they exactly? I think JamesB wanted only common 
>> transport values in the transport class. If it is driver specific then 
>> it should go on the host or target or device with the scsi_host_template 
>> attrs.
>>
> 
> It's a chicken & egg issue to put "port mapper" sysfs entry in scsi host
> attributes. Application won't see sysfs unless initiator creates an

Sorry for the late response. I was on vacation.

That is only with how you coded it today. I asked you to do something 
like qla4xxx where the session and host are not so closely bound.

> iSCSI session and driver can't create an iSCSI session without a tcp

That is not right with how things are today even. The iscsi_session 
struct can be created before the tcp connection. This was done because 
we thought we were going to have to use only sysfs for all setup and 
management (we ended up netlink and sysfs though).

> port. I was wondering if there is a better way than using IOCTL in this
> situation?
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--~--~---------~--~----~------------~-------~--~----~
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To unsubscribe from this group, send email to open-iscsi-unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi
-~----------~----~----~----~------~----~------~--~---
