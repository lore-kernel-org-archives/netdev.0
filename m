From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4 00/24] switchdev: spring cleanup
Date: Thu, 16 Apr 2015 21:48:12 -0700
Message-ID: <5530908C.6020601@cumulusnetworks.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com> <552CAA0C.3030009@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:36717 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbbDQEsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 00:48:16 -0400
Received: by qku63 with SMTP id 63so146618812qku.3
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 21:48:15 -0700 (PDT)
In-Reply-To: <552CAA0C.3030009@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/13/15, 10:47 PM, roopa wrote:
> On 4/12/15, 11:16 PM, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> v4:
>>
>> Well, it was a lot of work, but now prepare-commit transaction model 
>> is how
>> davem advises: if prepare fails, abort the transaction.  The driver 
>> must do
>> resource reservations up front in prepare phase and return those 
>> resources if
>> aborting.  Commit phase would use reserved resources.  The good news 
>> is the
>> driver code (for rocker) now handles resource allocation failures 
>> better by not
>> leaving partially device or driver states.  This is a side-effect of the
>> prepare phase where state isn't modified; only validation of inputs and
>> resource reservations happen in the prepare phase.  Since we're 
>> supporting
>> setting attrs and add objs across lower devs in the stacked case, we 
>> need to
>> hold rtnl_lock (or ensure rtnl_lock is held) so lower devs don't move 
>> on us
>> during the prepare-commit transaction.  DSA driver code skips the 
>> prepare phase
>> and goes straight for the commit phase since no up-front allocations 
>> are done
>> and no device failures (that could be detected in the prepare phase) can
>> happen.
>
> thanks for the series. It definitely does look cleaner and less 
> confusing now!.
> I do love the abstraction but i was one of the people voting against 
> duplicating the
> kernel objects into swdev objs which this patches does (which i am 
> still not convinced
> we should have).
>
>>
>> Remove NETIF_F_HW_SWITCH_OFFLOAD from rocker and the swdev_attr_set/get
>> wrappers.  DSA doesn't set NETIF_F_HW_SWITCH_OFFLOAD, so it can't be in
>> swdev_attr_set/get.  rocker doesn't need it; or rather can't support
>> NETIF_F_HW_SWITCH_OFFLOAD being set/cleared at run-time after the device
>> port is already up and offloading L2/L3. NETIF_F_HW_SWITCH_OFFLOAD is 
>> still
>> left as a feature flag for drivers that can use it.
>
> I see that this series removes all uses of it in the switchdev api 
> later. I had summarized
> the need for the flag in reply to one of your questions a few weeks 
> back. Since you have moved all
> ndo ops to swdev ops (including ndo_bridge_setlink/dellink), I don't 
> want to hold on to the
>  feature flag if no one is using it. yes, my userspace driver uses it 
> today.
> I will come back with stronger justification to keep it or
> will submit a patch to remove it and add it back at a later point if 
> needed.
>
scott,  I see that you will be spinning v5 of the series. In which case 
feel free to remove the feature flag during your
code restructuring effort. If i need it again, i will resubmit. thanks.
