From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] switchdev: add support for fdb add/del/dump
 via switchdev_port_obj ops.
Date: Thu, 07 May 2015 05:51:50 -0700
Message-ID: <554B5FE6.90507@cumulusnetworks.com>
References: <1430949253-6358-1-git-send-email-sridhar.samudrala@intel.com> <554AA530.7000702@mojatatu.com> <554AED2F.80006@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, sfeldma@gmail.com,
	netdev@vger.kernel.org
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36812 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbbEGMvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 08:51:52 -0400
Received: by pabsx10 with SMTP id sx10so39491083pab.3
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 05:51:52 -0700 (PDT)
In-Reply-To: <554AED2F.80006@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/6/15, 9:42 PM, Samudrala, Sridhar wrote:
>
>
> On 5/6/2015 4:35 PM, Jamal Hadi Salim wrote:
>> On 05/06/15 17:54, Sridhar Samudrala wrote:
>>> - introduce port fdb obj and generic switchdev_port_fdb_add/del/dump()
>>> - use switchdev_port_fdb_add/del/dump in rocker/team/bonding ndo ops.
>>> - add support for fdb obj in switchdev_port_obj_add/del/dump()
>>> - switch rocker to implement fdb ops via switchdev_ops
>>>
>>> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>> ---
>>
>> So i raised this earlier. DaveM also chimed in - but it seems still
>> in there.
>> i havent been following the discussion and i may have missed
>> the agreement to keep the new IDs. Could we not just have used netlink
>>  IDs (as opposed to a new SWITCHDEV_OBJ_PORT_FDB id)?
>
> I think you are referring to switch port attributes.  See Scott's 
> response here on
> using netlink IDs for attributes.
> http://thread.gmane.org/gmane.linux.network/357694/focus=357921
>
If you are using a global namespace for all switchdev objects/apis (as 
with scotts new patches), yes, using existing netlink id's and 
structures will not work as scott mentions in the link you point to 
above. But, if you were designing the api's for specific networking 
subsystems like it was initially, then netlink id's or existing 
structures will work.

And i am guessing Jamal is referring to the latter.

I did raise similar concerns earlier. Scotts patches do make the code 
way cleaner and less confusing than it was before (Thanks scott!). But, 
It does add this additional layer of mapping between kernel 
structures/objects and newly introduced switchdev structures/objects. 
The advantage of being in the kernel is access to existing kernel 
structures/objects. We lose that benefit.
